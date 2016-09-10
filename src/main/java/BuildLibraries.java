import com.github.mustachejava.DefaultMustacheFactory;
import com.github.mustachejava.Mustache;
import com.github.mustachejava.MustacheFactory;

import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBException;
import javax.xml.bind.Unmarshaller;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlRootElement;
import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;

/**
 * Created by seans on 05/09/16.
 */
public class BuildLibraries {
    static String MAVEN2 ="http://central.maven.org/maven2/";

    static String template = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" +
            "<SageTVPlugin>\n" +
            "    <Name>{{name}} Library</Name>\n" +
            "    <Identifier>{{name}}</Identifier>\n" +
            "    <Description>{{name}} library - dependency only</Description>\n" +
            "    <Author>SageTV</Author>\n" +
            "    <CreationDate>{{date}}</CreationDate>\n" +
            "    <ModificationDate>{{date}}</ModificationDate>\n" +
            "    <Version>{{version}}</Version>\n" +
            "    <ResourcePath>{{name}}</ResourcePath>\n" +
            "    <Webpage>{{url}}</Webpage>\n" +
            "    <PluginType>Library</PluginType>\n" +
            "    <Package>\n" +
            "        <PackageType>JAR</PackageType>\n" +
            "        <Location>{{url}}</Location>\n" +
            "        <MD5>{{md5}}</MD5>\n" +
            "        <Overwrite>true</Overwrite>\n" +
            "    </Package>\n" +
            "  <Dependency>\n" +
            "    <Core/>\n" +
            // NOTE: 9.0.7 was the first version to support direct JAR linking
            "    <MinVersion>9.0.7</MinVersion>\n" +
            "  </Dependency>\n" +
            "    <ReleaseNotes>\n" +
            "        {{name}} library\n" +
            "    </ReleaseNotes>\n" +
            "</SageTVPlugin>";

    static File dirIn, dirOut;

    @XmlRootElement(name = "dependency")
    @XmlAccessorType(XmlAccessType.FIELD)
    static class Dep {
        @XmlAttribute
        public String org;
        @XmlAttribute
        public String name;
        @XmlAttribute
        public String rev;
        // this is optional and would contain a version string to use for sagetv
        @XmlAttribute
        public String version;

        public String toUrl(String baseUrl) {
            if (baseUrl.endsWith("/")) {
                baseUrl=baseUrl.substring(0,baseUrl.length()-1);
            }

            baseUrl += ("/" + org.replace('.','/') + "/" + name + "/" + rev + "/" + name +"-"+rev+".jar");
            return baseUrl;
        }

        @Override
        public String toString() {
            return "Dep{" +
                    "org='" + org + '\'' +
                    ", name='" + name + '\'' +
                    ", rev='" + rev + '\'' +
                    '}';
        }
    }

    public static void main(String args[]) {
        dirIn = new File("src/libraries.in");
        dirOut = new File("build/libraries");
        dirOut.mkdirs();
        try {
            processLibraries();
        } catch (Throwable t) {
            t.printStackTrace();
            System.exit(1);
        }
    }

    public static void processLibraries() {
        Arrays.asList(dirIn.listFiles()).forEach(BuildLibraries::processFile);
    }

    public static void processFile(File file) {
        System.out.println("Processing File: " + file);
        if (file.getName().endsWith(".library")) {
            try {
                buildPluginOutput(file);
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
        }
    }

    private static void buildPluginOutput(File input) throws IOException {
        String name = parseName(input.getName());

        Dep dep = parseDep(input);
        String url = dep.toUrl(MAVEN2);
        if (testURL(url)) {
            System.out.println("URL is good: " + url);
        } else {
            throw new IOException("Invalid URL: " + url + " for dep " + dep);
        }

        HashMap<String, Object> scopes = new HashMap<String, Object>();
        scopes.put("name", name);
        scopes.put("url", url);
        scopes.put("version", (dep.version!=null)?dep.version:dep.rev);
        scopes.put("date", new SimpleDateFormat("yyyy-MM-dd").format(new Date()));
        scopes.put("md5", getUrlAsString(url + ".md5"));

        Writer writer = new OutputStreamWriter(new FileOutputStream(new File(dirOut, name+"-plugin.xml")));
        MustacheFactory mf = new DefaultMustacheFactory();
        Mustache mustache = mf.compile(new StringReader(template), "template");
        mustache.execute(writer, scopes);
        writer.flush();
        writer.close();
    }

    private static Dep parseDep(File input) {
        try {
            JAXBContext jc = JAXBContext.newInstance(Dep.class);
            Unmarshaller unmarshaller =  jc.createUnmarshaller();
            return  (Dep) unmarshaller.unmarshal(input);
        } catch (JAXBException e) {
            e.printStackTrace();
        }
        return null;
    }

    private static String parseName(String name) {
        return name.substring(0, name.lastIndexOf("."));
    }

    public static boolean testURL(String strUrl) {
        try {
            URL url = new URL(strUrl);
            HttpURLConnection urlConn = (HttpURLConnection) url.openConnection();
            urlConn.connect();
            urlConn.disconnect();
            return true;
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static String getUrlAsString(String urlStr)
    {
        StringBuilder sb = new StringBuilder();
        try
        {
            URL url = new URL(urlStr);
            InputStream is = url.openStream();
            BufferedReader br = new BufferedReader(new InputStreamReader(is));

            String line;
            while ( (line = br.readLine()) != null)
                sb.append(line);

            br.close();
            is.close();
        }
        catch (Exception e)
        {
        }
        return sb.toString();
    }
}

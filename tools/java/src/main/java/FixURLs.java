import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Stream;

/**
 * Created by seans on 05/09/16.
 */
public class FixURLs {

    public static void main(String args[]) throws IOException {
        Stream<String> stream = Files.lines(Paths.get(args[0]));
        stream.forEach(FixURLs::updateVersion);
    }

    static Pattern versionPattern = Pattern.compile("(.*)<Version([^>]*)>(.*)</Version>(.*)");
    static Pattern googlePattern = Pattern.compile("(.*)http://(.*).googlecode.com/files/(.*).zip(.*)");

    public static void updateVersion(String line) {
        Matcher versionMatcher = versionPattern.matcher(line);
        if (versionMatcher.matches()) {
            String out = "$1<Version$2>$3.7</Version>$4";
            System.out.println(versionMatcher.replaceFirst(out));
            return;
        }

        Matcher googleMatcher = googlePattern.matcher(line);
        if (googleMatcher.matches()) {
            System.out.println(googleMatcher.replaceFirst("$1http://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/$2/$3.zip$4"));
            return;
        }

        System.out.println(line);
    }
}

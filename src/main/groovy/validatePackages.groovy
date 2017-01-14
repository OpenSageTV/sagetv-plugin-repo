/**
 * Usage: groovy validatePackages.groovy DIR
 * eg, groovy validatePackages.groovy plugins/phoenix/
 *
 * Will download and validate the MD5 of the packages
 */

import groovy.io.FileType
import java.security.MessageDigest

def downloadFile(url, outFile) {
    def file = outFile.newOutputStream()
    file << new URL(url).openStream()
    file.close()
    return outFile;
}

def downloadToTmp(url) {
    def file = File.createTempFile("package-",".tmp");
    file.deleteOnExit()
    return downloadFile(url, file);
}

def generateMD5(File file) {
    return MessageDigest.getInstance("MD5").digest(file.bytes).encodeHex().toString();
}

def validatePackageUrl(String url, String md5) {
    println("Validating: ${url} with MD5 ${md5}");

    def md5Src = generateMD5(downloadToTmp(url))
    if (md5Src != md5) {
        println("MD5 Failed: Src: ${md5Src}, Orig: ${md5}; Url: ${url}")
        System.exit(2)
    }
    println("PASSED: ${url} with MD5 ${md5}\n");
}

def validatePackageUrls(File xmlFile) {
    if (!xmlFile.name.endsWith(".xml")) {
        println("TODO: Handle .url plugins")
        return;
    }
    println("Processing File: ${xmlFile}")
    def xml = new XmlSlurper().parse(xmlFile);
    xml.Package.each { p ->
        validatePackageUrl(p.Location.text().trim() as String, p.MD5.text().trim() as String)
    }
}

def validatePackages(File dirIn) {
    dirIn.eachFileRecurse(FileType.FILES) { file ->
        validatePackageUrls(file)
    }
}

/**
 * Entry Point
 */
if (args.length==0) {
    println("Must pass a directory")
    System.exit(1);
}

def dir = new File(args[0])
if (!dir.exists() || !dir.isDirectory()) {
    println("Must pass plugins directory")
    System.exit(1)
}

validatePackages(dir)
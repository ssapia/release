package net.ssapia.release;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import java.io.BufferedReader;
import java.io.File;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.stream.Collectors;


public class ReleaseApp {

    private static final String SNAPSHOT = "SNAPSHOT";
    private static String PATH;

    public static void main(String[] args) throws Exception {

        if (args.length != 2) {
            throw new Exception("Parametros inválidos");
        }

        PATH=args[0];
        String projeto=args[1];

        release(projeto);
    }

    public static void release(String projeto) throws Exception {

        Collection<Dependency> snapshots = getSnapshots(projeto);

        for (Dependency dependency: snapshots) {
            release(dependency.getArtifactId());
        }

        System.out.println(executeCommand(PATH+"/bin/release.sh --perform " + projeto));
    }


    private static Collection<Dependency> getSnapshots(String projeto) throws Exception {

        Collection<Dependency> dependencies = getDependencies(PATH+"/projects/"+projeto+"/pom.xml");

        List<Dependency> snapshots = dependencies.stream()
                .filter(dependency -> dependency.getVersion().contains(SNAPSHOT))
                .collect(Collectors.toList());

        return snapshots;
    }

    private static Collection<Dependency> getDependencies(String projeto) throws Exception {

        Collection<Dependency> dependencies = new ArrayList<>();

        File file = new File(projeto);
        if (!file.exists()) {
            throw new Exception("Projeto " + projeto + " não encontrado");
        }

        DocumentBuilderFactory documentBuilderFactory = DocumentBuilderFactory.newInstance();
        DocumentBuilder documentBuilder = documentBuilderFactory.newDocumentBuilder();
        Document document = documentBuilder.parse(file);

        NodeList dependency = document.getElementsByTagName("dependency");

        for (int i = 0; i < dependency.getLength(); ++i) {

            Element element = (Element) dependency.item(i);
            String artifactId = element.getElementsByTagName("artifactId").item(0).getTextContent();
            String version = element.getElementsByTagName("version").item(0).getTextContent();

            if (artifactId != null && !artifactId.isEmpty()
                    && version != null && !version.isEmpty()){

                dependencies.add(new Dependency(artifactId, version));
            }
        }

        return dependencies;
    }

    private static String executeCommand(String command) throws Exception {

        StringBuffer output = new StringBuffer();

        Process p;
        int statusCode = 0;
        try {
            p = Runtime.getRuntime().exec(command);
            statusCode = p.waitFor();
            BufferedReader reader = new BufferedReader(new InputStreamReader(p.getInputStream()));

            String line = "";
            while ((line = reader.readLine())!= null) {
                output.append(line + "\n");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        if (statusCode != 0) {
            throw new Exception("Status code:" + statusCode + "\n" +
                    output.toString());
        }

        return output.toString();
    }
}

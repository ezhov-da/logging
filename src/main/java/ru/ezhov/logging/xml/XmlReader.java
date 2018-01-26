package ru.ezhov.logging.xml;

import com.google.common.base.Charsets;
import java.util.logging.Logger;
import com.google.common.io.Resources;
import java.io.IOException;
import java.net.URL;
import java.util.logging.Level;

/**
 *
 * @author ezhov_da
 */
public class XmlReader
{
    private static final Logger LOG = Logger.getLogger(XmlReader.class.getName());

    public String textXml()
    {
        try
        {
            return read("/ru/ezhov/logging/log.xml");
        } catch (IOException ex)
        {
            Logger.getLogger(XmlReader.class.getName()).log(Level.SEVERE, null, ex);
        }
        return "";
    }

    public String textSchema()
    {
        try
        {
            return read("/ru/ezhov/logging/log.xsd");
        } catch (IOException ex)
        {
            Logger.getLogger(XmlReader.class.getName()).log(Level.SEVERE, null, ex);
        }
        return "";
    }

    private String read(String pathToFile) throws IOException
    {

        URL url = XmlReader.class.getResource(pathToFile);
        String text = Resources.toString(url, Charsets.UTF_8);
        return text
                .replaceAll("<", "&lt;")
                .replaceAll(">", "&gt;");

    }
}

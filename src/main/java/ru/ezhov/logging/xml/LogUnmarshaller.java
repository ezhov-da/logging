package ru.ezhov.logging.xml;

import java.io.StringReader;
import java.util.logging.Logger;
import javax.xml.XMLConstants;
import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBException;
import javax.xml.bind.Unmarshaller;
import javax.xml.validation.Schema;
import javax.xml.validation.SchemaFactory;
import org.xml.sax.SAXException;
import ru.ezhov.logging.beans.Log;

/**
 *
 * @author ezhov_da
 */
public class LogUnmarshaller
{
    private static final Logger LOG = Logger.getLogger(LogUnmarshaller.class.getName());
    private String xmlFromUrl;

    public LogUnmarshaller(String xmlFromUrl)
    {
        this.xmlFromUrl = xmlFromUrl;
    }

    public Log unmarshaller() throws JAXBException, SAXException
    {
        JAXBContext jaxbContext = JAXBContext.newInstance(Log.class);

        Unmarshaller jaxbUnmarshaller = jaxbContext.createUnmarshaller();

        SchemaFactory schemaFactory =
                SchemaFactory.newInstance(XMLConstants.W3C_XML_SCHEMA_NS_URI);

        Schema schema = schemaFactory.newSchema(LogUnmarshaller.class.getResource("/ru/ezhov/logging/log.xsd"));

        jaxbUnmarshaller.setSchema(schema);

        StringReader stringReader = new StringReader(xmlFromUrl);

        Log log = (Log) jaxbUnmarshaller.unmarshal(stringReader);

        return log;
    }
}

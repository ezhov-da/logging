package ru.ezhov.logging.beans;

import java.util.logging.Logger;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

/**
 *
 * @author ezhov_da
 */
@XmlRootElement
public class Errors
{
    private static final Logger LOG = Logger.getLogger(Errors.class.getName());
    private String error;

    public Errors()
    {
    }

    public Errors(String error)
    {
        this.error = error;
    }


    public String getError()
    {
        return error;
    }

    @XmlElement
    public void setError(String error)
    {
        this.error = error;
    }


}

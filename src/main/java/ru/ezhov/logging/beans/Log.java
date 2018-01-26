package ru.ezhov.logging.beans;

import com.google.common.base.MoreObjects;
import java.util.logging.Logger;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

/**
 *
 * @author ezhov_da
 */
@XmlRootElement
public class Log
{
    private static final Logger LOG = Logger.getLogger(Log.class.getName());

    private int idTool;
    private int idLog;
    private String username;
    private String computerName;
    private String computerIp;
    private String receiptDate;
    private String messageShot;
    private String messageDetail;
    private String error;
    private String extendedInformation;

    public Log()
    {
    }

    public int getIdTool()
    {
        return idTool;
    }

    @XmlAttribute
    public void setIdTool(int idTool)
    {
        this.idTool = idTool;
    }

    public int getIdLog()
    {
        return idLog;
    }

    @XmlAttribute
    public void setIdLog(int idLog)
    {
        this.idLog = idLog;
    }

    public String getUsername()
    {
        return username;
    }

    @XmlAttribute
    public void setUsername(String username)
    {
        this.username = username;
    }

    public String getComputerName()
    {
        return computerName;
    }

    @XmlAttribute
    public void setComputerName(String computerName)
    {
        this.computerName = computerName;
    }

    public String getComputerIp()
    {
        return computerIp;
    }

    @XmlAttribute
    public void setComputerIp(String computerIp)
    {
        this.computerIp = computerIp;
    }

    public String getReceiptDate()
    {
        return receiptDate;
    }

    @XmlAttribute
    public void setReceiptDate(String receiptDate)
    {
        this.receiptDate = receiptDate;
    }

    public String getMessageShot()
    {
        return messageShot;
    }

    @XmlElement
    public void setMessageShot(String messageShot)
    {
        this.messageShot = messageShot;
    }

    public String getMessageDetail()
    {
        return messageDetail;
    }

    @XmlElement
    public void setMessageDetail(String messageDetail)
    {
        this.messageDetail = messageDetail;
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

    public String getExtendedInformation()
    {
        return extendedInformation;
    }

    @XmlElement
    public void setExtendedInformation(String extendedInformation)
    {
        this.extendedInformation = extendedInformation;
    }

    @Override
    public String toString()

    {
        String s = MoreObjects.toStringHelper(this)
                .add("idTools", idTool)
                .add("idLog", idLog)
                .add("computerName", computerName)
                .add("computerIp", computerIp)
                .add("receiptDate", receiptDate)
                .toString();
        return s;
    }


}

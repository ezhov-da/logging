package ru.ezhov.logging.db;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.Types;
import java.util.logging.Logger;
import javax.naming.InitialContext;
import javax.sql.DataSource;
import ru.ezhov.logging.beans.Log;

/**
 *
 * @author ezhov_da
 */
public class LogTreatment
{
    private static final Logger LOG = Logger.getLogger(LogTreatment.class.getName());
    private Log log;

    public LogTreatment(Log log)
    {
        this.log = log;
    }

    public String treatment(String queryPrcExecuteFromContext) throws Exception
    {

        InitialContext cxt = new InitialContext();
        if (cxt == null)
        {
            throw new Exception("Uh oh -- no context!");
        }

        DataSource ds = (DataSource) cxt.lookup("java:comp/env/jdbc/mssql-otzprod1");

        if (ds == null)
        {
            throw new Exception("Data source not found!");
        }

        try (Connection connection = ds.getConnection();)
        {
            try (CallableStatement statement = connection.prepareCall(queryPrcExecuteFromContext);)
            {
                statement.registerOutParameter(11, Types.LONGVARCHAR);
                statement.setInt(1, log.getIdTool());
                statement.setInt(2, log.getIdLog());
                statement.setString(3, log.getUsername());
                statement.setString(4, log.getComputerName());
                statement.setString(5, log.getComputerIp());
                statement.setString(6, log.getReceiptDate());
                statement.setString(7, log.getMessageShot());
                statement.setString(8, log.getMessageDetail());
                statement.setString(9, log.getError());
                statement.setString(10, log.getExtendedInformation());

                statement.execute();

                String result = statement.getString(11);
                return result;
            }
        }

    }
}

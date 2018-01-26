package ru.ezhov.logging.servlets;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import ru.ezhov.logging.beans.Log;
import ru.ezhov.logging.db.LogTreatment;

/**
 * Тест внесения некорректного лога
 * <p>
 * @author ezhov_da
 */
public class SrvltTestInsertLogToBase extends HttpServlet
{

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code> methods.
     * <p>
     * @param request  servlet request
     * @param response servlet response
     * <p>
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException      if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException
    {
        response.setContentType("text/xml;charset=UTF-8");
        String result = "";
        try (PrintWriter out = response.getWriter())
        {

            Log log = new Log();
            log.setIdTool(-100);
            log.setIdLog(12);
            log.setUsername("TEST");
            log.setComputerName("C_TEST");
            log.setComputerIp("C_I_TEST");
            log.setReceiptDate("2017-03-28 12:25:15");
            log.setMessageShot("SHORT");
            log.setMessageDetail("DETAIL");
            log.setError("ERROR");
            log.setExtendedInformation("EXT_INFO");

            LogTreatment logTreatment = new LogTreatment(log);
            try
            {
                result = logTreatment.treatment("{call OTZ.dbo.prc_E_serviceLog_treatment(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)}");

                out.println(result);

            } catch (Exception ex)
            {
                out.println(result);
            }
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     * <p>
     * @param request  servlet request
     * @param response servlet response
     * <p>
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException      if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException
    {
        processRequest(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     * <p>
     * @param request  servlet request
     * @param response servlet response
     * <p>
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException      if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException
    {
        processRequest(request, response);
    }

    /**
     * Returns a short description of the servlet.
     * <p>
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo()
    {
        return "Short description";
    }// </editor-fold>

}

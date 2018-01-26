package ru.ezhov.logging.servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.Scanner;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.xml.bind.JAXBContext;
import javax.xml.bind.Marshaller;
import ru.ezhov.logging.beans.Errors;
import ru.ezhov.logging.beans.Log;
import ru.ezhov.logging.db.LogTreatment;
import ru.ezhov.logging.xml.LogUnmarshaller;

/**
 * Сервлет, который отвечает за логирование в БД
 * <p>
 * @author ezhov_da
 */
public class SrvltLogger extends HttpServlet
{
    private static final Logger LOG = Logger.getLogger(SrvltLogger.class.getName());
    private HttpServletRequest request;
    private HttpServletResponse response;


    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException
    {
        this.request = request;
        this.response = response;
        request.setCharacterEncoding("UTF-8");
        try (PrintWriter out = response.getWriter())
        {
            try
            {
                LOG.info(request.getContentType());

                String xmlText = getXmlTextFromRequest();

                LogUnmarshaller logUnmarshaller = new LogUnmarshaller(xmlText);
                Log log = logUnmarshaller.unmarshaller();

                LogTreatment treatment = new LogTreatment(log);

                String query = getServletContext().getInitParameter("prc.treatment");

                String string = treatment.treatment(query);

                response.setContentType("text/xml;charset=UTF-8");
                if ("".equals(string))
                {
                    response.setStatus(HttpServletResponse.SC_OK);
                } else
                {
                    out.print(string);
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                }

            } catch (Exception ex)
            {
                try
                {
                    String s = getExceptionMsg(ex);
                    out.print(s);
                    LOG.log(Level.SEVERE, "Ошибка обработки.", ex);
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                } catch (Exception ex1)
                {
                    LOG.log(Level.SEVERE, null, ex1);
                }

            }
        }
    }


    private String getXmlTextFromRequest() throws IOException
    {
        try (Scanner scanner = new Scanner(request.getInputStream(), "UTF-8");)
        {
            StringBuilder stringBuider = new StringBuilder();
            while (scanner.hasNextLine())
            {
                stringBuider.append(scanner.nextLine());
            }

            String textFromUrl = stringBuider.toString();
            return textFromUrl;
        }
    }

    private String getExceptionMsg(Exception exception) throws Exception
    {
        try (StringWriter stringWriter = new StringWriter();)
        {
            try (PrintWriter printWriter = new PrintWriter(stringWriter);)
            {
                exception.printStackTrace(printWriter);

                String error = stringWriter.toString();
                Errors errors = new Errors();
                errors.setError(error);

                JAXBContext jaxbContext = JAXBContext.newInstance(Errors.class);
                Marshaller marshaller = jaxbContext.createMarshaller();
                try (StringWriter stringWriterMarshaller = new StringWriter();)
                {
                    marshaller.marshal(errors, stringWriterMarshaller);
                    return stringWriterMarshaller.toString();
                }
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

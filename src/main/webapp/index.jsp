<%-- 
    Document   : index
    Created on : 22.03.2017, 16:14:35
    Author     : ezhov_da
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>

<html>

    <%@include file="WEB-INF/jspf/head.jspf" %>

    <body>

        <div class="navbar navbar-inverse navbar-fixed-top">
            <div class="navbar-inner">
                <div class="container">
                    <a class="brand" href="#">Система логирования ДТРРЗ</a>
                </div>
            </div>
        </div>

        <div class="container">

            <%@include file="WEB-INF/jspf/log_content.jspf" %>

        </div> <!-- /container -->

        <%@include file="WEB-INF/jspf/footer.jspf" %>>

        <!-- Le javascript
        ================================================== -->
        <!-- Placed at the end of the document so the pages load faster -->
        <script src="/wp-content/themes/clear-theme/js/jquery.js"></script>
        <script src="/wp-content/themes/clear-theme/js/bootstrap-transition.js"></script>
        <script src="/wp-content/themes/clear-theme/js/bootstrap-alert.js"></script>
        <script src="/wp-content/themes/clear-theme/js/bootstrap-modal.js"></script>
        <script src="/wp-content/themes/clear-theme/js/bootstrap-dropdown.js"></script>
        <script src="/wp-content/themes/clear-theme/js/bootstrap-scrollspy.js"></script>
        <script src="/wp-content/themes/clear-theme/js/bootstrap-tab.js"></script>
        <script src="/wp-content/themes/clear-theme/js/bootstrap-tooltip.js"></script>
        <script src="/wp-content/themes/clear-theme/js/bootstrap-popover.js"></script>
        <script src="/wp-content/themes/clear-theme/js/bootstrap-button.js"></script>
        <script src="/wp-content/themes/clear-theme/js/bootstrap-collapse.js"></script>
        <script src="/wp-content/themes/clear-theme/js/bootstrap-carousel.js"></script>
        <script src="/wp-content/themes/clear-theme/js/bootstrap-typeahead.js"></script>


    </body>
</html>
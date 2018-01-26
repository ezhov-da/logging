Attribute VB_Name = "WebLogging"
'---------------------------------------------------------------------------------------------------------
'Название:      Модуль логирования VBA для Cистемы логирования
'Версия модуля: 0.3а
'Разработчик:   Ежов Денис Анатольевич <ezhov_da@magnit.ru>
'Описание:      Данный модуль использует HTTP соединение для внесения данных логируемого приложения в БД
'---------------------------------------------------------------------------------------------------------

Option Explicit

'КОНСТАНТЫ ДЛЯ ИЗМЕНЕНИЯ РАЗРАБОТЧИКОМ-ПОЛЬЗОВАТЕЛЕМ СИСТЕМЫ-------------------------------------------------------------

Private Const ID_TOOL  As String = "1"  'ID выдается при регистрации инструмента логирования

'URL логирования, меняется только в случае изменения сервера
Private Const URL  As String = "http://office6887:8080/logging/logger"


'КОНСТАНТЫ ДЛЯ ДЛЯ РАЗРАБОТЧИКА НЕ МЕНЯТЬ-------------------------------------------------------------------------------

Private Const DEBUG_MODE  As Boolean = True                                             '- режим логирования
Private Const METHOD  As String = "POST"                                                '- метод отправки
Private Const CONTENT_TYPE  As String = "text/xml;charset=utf-8"                        '- тип передаваемых данных
Private Const ACCEPT_LANG  As String = "en"                                             '- язык
Private Const NAME_FILE_LOG_STORAGE As String = "NOT_SENT_LOGS_STORAGE_SERVICE.xml"     '- хранилище неотправленных логов
Private Const STATUS_OK As String = "OK"
Private Const STATUS_BAD_REQUEST As String = "Bad Request"
Private Const STATUS_PAGE_NOT_FOUND As String = "Not Found"


'xml
Private Const NODE_LOGS As String = "logs"
Private Const NODE_LOG As String = "log"
Private Const NODE_MESSAGE_SHORT As String = "messageShot"
Private Const NODE_MESSAGE_DETAIL As String = "messageDetail"
Private Const NODE_ERROR As String = "error"
Private Const NODE_EXTENDED_INFORMATION As String = "extendedInformation"


Private Const ATTRIBUTE_ID_TOOL As String = "idTool"
Private Const ATTRIBUTE_ID_LOG As String = "idLog"
Private Const ATTRIBUTE_USERNAME As String = "username"
Private Const ATTRIBUTE_COMPUTER_NAME As String = "computerName"
Private Const ATTRIBUTE_COMPUTER_IP As String = "computerIp"
Private Const ATTRIBUTE_RECEIPT_DATE As String = "receiptDate"

'уровни логирования
Public Enum LogLevel
     LOG_LEVEL_SEVERE = 7
     LOG_LEVEL_WARNING = 6
     LOG_LEVEL_INFO = 5
     LOG_LEVEL_CONFIG = 4
     LOG_LEVEL_FINE = 3
     LOG_LEVEL_FINER = 2
     LOG_LEVEL_FINEST = 1
End Enum
 
'переменная, которая хранит последний текст обработки запроса
'присваивание запроса происходит только в случает статуса ответа STATUS_BAD_REQUEST
Private lastTextResponse As String
 

'МЕТОДЫ ДЛЯ РАБОТЫ С ЛОГИРОВАНИЕ РАЗРАБОТЧИКА ПОЛЬЗОВАТЕЛЯ----------------------------------------------

Public Sub sendLogFull( _
    username As String, _
    levelLog As LogLevel, _
    messageShot As String, _
    messageDetail As String, _
    error As String, _
    extInfo As String _
)
     Call logExecutor(username, levelLog, messageShot, messageDetail, error, extInfo)
End Sub

Public Sub sendLogLong( _
    levelLog As LogLevel, _
    messageShot As String, _
    messageDetail As String, _
    error As String, _
    extInfo As String _
)

    Dim username As String: username = ""

    Call logExecutor(username, levelLog, messageShot, messageDetail, error, extInfo)
End Sub


Public Sub sendLogShort( _
    levelLog As LogLevel, _
    messageShot As String, _
    messageDetail As String, _
    extInfo As String _
)

    Dim username As String: username = ""
    Dim error As String: error = ""


    Call logExecutor(username, levelLog, messageShot, messageDetail, error, extInfo)
End Sub


'||
'||
'||
'||
'||
'V

'----------------------------------------------------------------------------------------------------
'ВСЕ ЧТО НИЖЕ НЕПОСРЕДСТВЕННО КОД ОБРАБОТКИ, ЕГО НЕ НУЖНО МЕНЯТЬ
'----------------------------------------------------------------------------------------------------

'ИСПОЛЬЗУЕТСЯ ТОЛЬКО РАЗРАБОТЧИКАМИ-------------------------------------------------------------------
Public Sub notUseTestLog()
     Call sendLogFull("", LogLevel.LOG_LEVEL_INFO, "ezhov_da", "ezhov_da", "ezhov_da", "")
     'Call sendLogLong("", "", "")
     'Call sendLogShort("", "")
     'Call createXml
End Sub

'формирование и отправка лога
Private Sub logExecutor( _
    username As String, _
    levelLog As LogLevel, _
    messageShot As String, _
    messageDetail As String, _
    error As String, _
    extInfo As String _
)

    Dim xmlLogNode As IXMLDOMNode
    Set xmlLogNode = _
        createXml( _
            username, _
            levelLog, _
            messageShot, _
            messageDetail, _
            error, _
            extInfo _
        )
    
    Dim postText As String
    postText = xmlLogNode.xml
    
    Call debugSystem("xml", postText)

    Dim statusTextResponse As String
    
    statusTextResponse = logSendToBase(postText)
   
    'если получили некорректный запрос, значит проблема
    'с поступающими данными и разработчик должен сразу откорректировать
    If (statusTextResponse = STATUS_BAD_REQUEST) Then
        MsgBox _
        "Возникла ошибка при при отправке запроса: " & vbNewLine & lastTextResponse, _
        vbOKOnly, _
        "Ошибка формирования запроса"
        Exit Sub
    End If
   
    'здесь просто проверяем на ошибку например доступности сервера и производим сохранение
    'в хранилище xml
    If Err.Number > 0 Or statusTextResponse = STATUS_PAGE_NOT_FOUND Then
    'ВАЖНО! Функция [logSendToBase] использует On Error resume next для отлова ошибок вне функции
    'после обработки ошибки необходимо восстановить нормальную обработку ошибок
    On Error GoTo 0
            Call debugSystem("ошибка", Err.description)
            Call debugSystem("статус", statusTextResponse)
            Call saveXmlToStorage(xmlLogNode)
        Else
            Call addSaveLogsStorageToBase
    End If
End Sub

'Отправка лога по URL

'ВАЖНО! Функция [logSendToBase] использует On Error resume next для отлова ошибок вне функции
'после обработки ошибки необходимо восстановить нормальную обработку ошибок On Error GoTo 0
Private Function logSendToBase(xmlLogNode As String) As String
    On Error Resume Next
    
    Dim oXmlHttp As MSXML2.XMLHTTP30
    Set oXmlHttp = New MSXML2.XMLHTTP30

    oXmlHttp.Open METHOD, URL, False
    oXmlHttp.setRequestHeader "Content-Type", CONTENT_TYPE
    oXmlHttp.setRequestHeader "Accept-Language", ACCEPT_LANG

    oXmlHttp.send xmlLogNode

    Dim statusTextResponse As String: statusTextResponse = oXmlHttp.statusText

    Call debugSystem("Статус ответа", statusTextResponse)

    Dim responseText As String
    responseText = oXmlHttp.responseText

    If (statusTextResponse = STATUS_BAD_REQUEST) Then
        lastTextResponse = responseText
    End If

    oXmlHttp.abort
    Set oXmlHttp = Nothing

    'Dim generateError As Integer: generateError = 1 / 0
    
    logSendToBase = statusTextResponse
    
End Function

'Создание XML лога, именно здесь происходит формирование объекта для внесения
Private Function createXml( _
    usernameParam As String, _
    levelLog As LogLevel, _
    messageShotParam As String, _
    messageDetailParam As String, _
    errorParam As String, _
    extInfoParam As String _
) As IXMLDOMNode
    Dim xml As New MSXML2.DOMDocument30
       
    Dim nodeMsgShort As MSXML2.IXMLDOMNode
    Set nodeMsgShort = xml.createNode(1, NODE_MESSAGE_SHORT, "")
    
    Dim nodeMsgShortData As MSXML2.IXMLDOMCharacterData
    Set nodeMsgShortData = xml.createTextNode(messageShotParam)
    
    nodeMsgShort.appendChild nodeMsgShortData
    
    Dim nodeMsgDetail As IXMLDOMNode
    Set nodeMsgDetail = xml.createNode(1, NODE_MESSAGE_DETAIL, "")
    
    Dim nodeMsgDetailData As MSXML2.IXMLDOMCharacterData
    Set nodeMsgDetailData = xml.createTextNode(messageDetailParam)
    
    nodeMsgDetail.appendChild nodeMsgDetailData
    
    Dim nodeMsgError As IXMLDOMNode
    Set nodeMsgError = xml.createNode(1, NODE_ERROR, "")
    
    Dim nodeMsgErrorData As MSXML2.IXMLDOMCharacterData
    Set nodeMsgErrorData = xml.createTextNode(errorParam)
    
    nodeMsgError.appendChild nodeMsgErrorData
    
    Dim nodeMsgExtendedInfo As IXMLDOMNode
    Set nodeMsgExtendedInfo = xml.createNode(1, NODE_EXTENDED_INFORMATION, "")
    
    Dim nodeMsgExtInfoData As MSXML2.IXMLDOMCharacterData
    Set nodeMsgExtInfoData = xml.createTextNode(extInfoParam)
    
    nodeMsgExtendedInfo.appendChild nodeMsgExtInfoData
       
    Dim nodeBasicLog As IXMLDOMNode
    Set nodeBasicLog = xml.createNode(1, NODE_LOG, "")
    
    Dim idTool As IXMLDOMAttribute
    Set idTool = xml.createAttribute(ATTRIBUTE_ID_TOOL)
    idTool.Value = ID_TOOL
    
    Dim idLog As IXMLDOMAttribute
    Set idLog = xml.createAttribute(ATTRIBUTE_ID_LOG)
    idLog.Value = levelLog
    
    Dim username As IXMLDOMAttribute
    Set username = xml.createAttribute(ATTRIBUTE_USERNAME)
    username.Value = getUsername(usernameParam)
    
    Dim computerName As IXMLDOMAttribute
    Set computerName = xml.createAttribute(ATTRIBUTE_COMPUTER_NAME)
    computerName.Value = getComputerName()
    
    Dim computerIp As IXMLDOMAttribute
    Set computerIp = xml.createAttribute(ATTRIBUTE_COMPUTER_IP)
    computerIp.Value = getIpAddress()
    
    Dim receiptDate As IXMLDOMAttribute
    Set receiptDate = xml.createAttribute(ATTRIBUTE_RECEIPT_DATE)
    receiptDate.Value = getReceiptDate()
    
   
    nodeBasicLog.Attributes.setNamedItem idTool
    nodeBasicLog.Attributes.setNamedItem idLog
    nodeBasicLog.Attributes.setNamedItem username
    nodeBasicLog.Attributes.setNamedItem computerName
    nodeBasicLog.Attributes.setNamedItem computerIp
    nodeBasicLog.Attributes.setNamedItem receiptDate
   
    nodeBasicLog.appendChild nodeMsgShort
    nodeBasicLog.appendChild nodeMsgDetail
    nodeBasicLog.appendChild nodeMsgError
    nodeBasicLog.appendChild nodeMsgExtendedInfo
    
    Set createXml = nodeBasicLog
End Function

'Сохранение лога в хранилище в случае ошибки внесения
Private Sub saveXmlToStorage(xmlLog As IXMLDOMNode)
    
    Dim logStorageNotBuild As Boolean: logStorageNotBuild = isLogStorageNotBuild()
    
    Dim fullPathToStorage As String: fullPathToStorage = getFullPathToUserLogsStorage
    
    Dim xml As New MSXML2.DOMDocument30

    Dim basicNode As IXMLDOMNode
        
    If (logStorageNotBuild) Then

        Set basicNode = xml.createNode(1, NODE_LOGS, "")
        xml.appendChild basicNode
    Else
        xml.load fullPathToStorage
        Dim logsNode As IXMLDOMNodeList
        Set logsNode = xml.getElementsByTagName(NODE_LOGS)
        Set basicNode = logsNode.Item(0)
    End If
    
    basicNode.appendChild xmlLog
    
    Call debugSystem("", "лог сохранен в локальное хранилище")
    
    xml.Save fullPathToStorage
End Sub

'Проверка на созданность хранилища
Private Function isLogStorageNotBuild() As Boolean
    Dim pathToStorage As String: pathToStorage = getFullPathToUserLogsStorage()
    isLogStorageNotBuild = Dir(pathToStorage) = ""
    Call debugSystem("хранилище отсутствует", isLogStorageNotBuild)
End Function

'Получение полного пути к хранилищу неотправленных логов
Private Function getFullPathToUserLogsStorage() As String
    getFullPathToUserLogsStorage = getEnv("USERPROFILE") & "\" & NAME_FILE_LOG_STORAGE
    
    Call debugSystem("путь к хранилищу логов", getFullPathToUserLogsStorage)
End Function

'Обработка ранее необработанных логов
Private Sub addSaveLogsStorageToBase()
    Dim logStorageNotBuild As Boolean: logStorageNotBuild = isLogStorageNotBuild()

    If (Not logStorageNotBuild) Then
    
        Dim xml As New MSXML2.DOMDocument30
        Dim basicNode As IXMLDOMNode
        Dim fullPathToStorage As String: fullPathToStorage = getFullPathToUserLogsStorage
        xml.load fullPathToStorage
        
        Set basicNode = xml.CloneNode(True).FirstChild
                
        Dim countChild As Integer: countChild = basicNode.ChildNodes.Length
        
        If (countChild > 0) Then
            Dim c  As Integer
            
            For c = 0 To countChild
                Dim childLog As IXMLDOMNode
                Set childLog = basicNode.ChildNodes.Item(c)
                
                Dim statusTextResponse As String
                statusTextResponse = logSendToBase(childLog.xml)
            
                If Err.Number > 0 Or statusTextResponse <> STATUS_OK Then
                'ВАЖНО! Функция [logSendToBase] использует On Error resume next для отлова ошибок вне функции
                'после обработки ошибки необходимо восстановить нормальную обработку ошибок
                On Error GoTo 0
                        'если после попытки внесения появилась ошибка,
                        'значит сохраняем то что еще не внесли и выходим
                        Exit For

                    Else
                        'при удачном внесении удаляем лог
                        'и пересчитываем кол-во + счетчик на 0
                        basicNode.RemoveChild childLog
                        countChild = basicNode.ChildNodes.Length
                        c = -1
                        'считаем, если детей не осталось, выходим из цикла
                        If (countChild = 0) Then Exit For
                End If
            
            Next c
            
            Dim logsNode As IXMLDOMNodeList
            Set logsNode = xml.getElementsByTagName(NODE_LOGS)
            Dim basicNodeForDelete As IXMLDOMNode
            Set basicNodeForDelete = logsNode.Item(0)
            xml.RemoveChild basicNodeForDelete
            xml.appendChild basicNode
            xml.Save fullPathToStorage
        End If
        
    End If
End Sub


Private Function getUsername(un As String) As String
    If (un = "") Then
        Dim username As String: username = getEnv("USERNAME")
        Call debugSystem("имя пользователя", username)
        getUsername = username
    Else
        getUsername = un
    End If
End Function

Private Function getComputerName() As String
    Dim computerName As String: computerName = getEnv("COMPUTERNAME")
    Call debugSystem("имя компьютера", computerName)
    getComputerName = computerName
End Function

Private Function getEnv(nameEnv As String) As String
    getEnv = Environ(nameEnv)
End Function

Private Function getIpAddress() As String
    Dim strQuery As String
    strQuery = "SELECT * FROM Win32_NetworkAdapterConfiguration WHERE MACAddress > ''"
    Dim objWMIService
    Set objWMIService = GetObject("winmgmts://./root/CIMV2")
    Dim colItems
    Set colItems = objWMIService.ExecQuery(strQuery, "WQL", 48)
    Dim objItem
    For Each objItem In colItems
        If IsArray(objItem.IPAddress) Then
            getIpAddress = objItem.IPAddress(0)
            Exit Function
        End If
    Next
End Function


Private Function getReceiptDate() As String
    Dim receiptDate As String
    receiptDate = Format(Now(), "yyyy-MM-dd hh:mm:ss")
    Call debugSystem("дата лога", receiptDate)
    getReceiptDate = receiptDate
End Function

'Внутренний метод логирования
Private Sub debugSystem(textDebug As String, valDebug)
    If (DEBUG_MODE) Then
    
        If (textDebug = "") Then
            Debug.Print valDebug
        Else
            Debug.Print textDebug & " : " & valDebug
        End If
        
    End If
End Sub


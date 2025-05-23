#include "totvs.ch"
#include "rwmake.ch"
#include "protheus.ch"
#include "tbiconn.ch"
#include "tbicode.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � U6COM003 �  Autor � F�brica ERPBR   � Data  � 19/04/2023   ���
��+----------+------------------------------------------------------------���
���Descricao � Envia pedido de compras por e-mail.						  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo INTRALOX 										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function U6COM003()

Local nOpc410 := 0
Local bActOk  := {|| nOpc410:=1,oDlg410:End()}
Local bActCan := {|| nOpc410:=0,oDlg410:End()}
Local bOk410  := {|| IIf( MsgYesNo("Confirma?","Confirmar"), Eval(bActOk), .F.) }
Local bCan410 := {|| IIf( MsgYesNo("Abandona?","Sair"), Eval(bActCan), .F.) }

Private lMsErroAuto := .F.
Private oOk := LoadBitmap( GetResources(), "LBOK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )
Private oDlg410
Private oFnt1,oFnt2,oFnt3,oFnt4,oFntM

Private cMailFor := Space(100)
Private cMailRec := Space(100)
Private cMailPcp := Space(100)
Private cMailCop := Space(100)
Private oSayCod,oSayNom,oSayNew

If !(FWCodEmp() $("99,U6"))
	MsgAlert("Empresa n�o autorizada: "+FWCodEmp())
	Return
Endif

DbSelectArea("SA2")
DbSetOrder(1)
DbSeek( xFilial("SA2") + SC7->C7_FORNECE + SC7->C7_LOJA )
If !Empty(SA2->A2_EMAIL)
	cMailFor := PadR( AllTrim(SA2->A2_EMAIL), 100 )
	If SA2->(FieldPos("A2_ZEMLREC")) > 0
		cMailRec := PadR( AllTrim(SA2->A2_ZEMLREC), 100 )
	Endif
	If SA2->(FieldPos("A2_ZEMLPCP")) > 0
		cMailPcp := PadR( AllTrim(SA2->A2_ZEMLPCP), 100 )
	Endif
Endif

oFnt1 := TFont():New("Tahoma",,23,,.T.)
oFnt2 := TFont():New("Tahoma",,12,,.T.)
oFnt3 := TFont():New("Tahoma",,14,,.F.)
oFnt4 := TFont():New("Tahoma",,11,,.T.)
oFntM := TFont():New("Tahoma",,11,,.F.)

nDlg1 := 001
nDlg2 := 001
nDlg3 := 210
nDlg4 := 700

oDlg410 := MsDialog():New(nDlg1,nDlg2,nDlg3,nDlg4,"Pedido de Compra "+SC7->C7_NUM,,,,,CLR_BLACK,CLR_WHITE,,,.T.)

@ 040,005 SAY "E-Mail Fornecedor" OF oDlg410 PIXEL SIZE 055,009
@ 039,060 MSGET oMailFor VAR cMailFor SIZE 250,010 OF oDlg410 PIXEL PICTURE "@X"

@ 055,005 SAY "E-Mail Recebto." OF oDlg410 PIXEL SIZE 055,009
@ 054,060 MSGET oCopia1 VAR cMailRec SIZE 250,010 OF oDlg410 PIXEL PICTURE "@X"

@ 070,005 SAY "E-Mail PCP" OF oDlg410 PIXEL SIZE 055,009
@ 069,060 MSGET oCopia2 VAR cMailPcp SIZE 250,010 OF oDlg410 PIXEL PICTURE "@X"

@ 085,005 SAY "C�pia" OF oDlg410 PIXEL SIZE 055,009
@ 084,060 MSGET oCopia3 VAR cMailCop SIZE 250,010 OF oDlg410 PIXEL PICTURE "@X"

oDlg410:Activate(,,,.T.,{|| ValidEml() },,{|| EnchoiceBar(oDlg410,bOk410,bCan410) } )

If nOpc410 == 1
	MsgRun("Aguarde, gerando pdf...","Processando",{|| PedcPdf() })
	MsgRun("Aguarde, enviando email...","Processando",{|| SendPedc() })
Endif

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    � ValidEml �  Autor � F�brica ERPBR   � Data  � 19/04/2023   ���
��+----------+------------------------------------------------------------���
���Descricao � Valida endere�os de e-mail.								  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo INTRALOX 										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function ValidEml()

Local lRetOk := .T.

If AT("@",cMailFor) == 0
	MsgAlert("E-Mail inv�lido - Fornecedor.")
	lRetOk := .F.
ElseIf !Empty(cMailRec) .And. AT("@",cMailRec) == 0
	MsgAlert("E-Mail inv�lido - Recebimento")
	lRetOk := .F.
ElseIf !Empty(cMailPcp) .And. AT("@",cMailPcp) == 0
	MsgAlert("E-Mail inv�lido - PCP")
	lRetOk := .F.
ElseIf !Empty(cMailCop) .And. AT("@",cMailCop) == 0
	MsgAlert("E-Mail inv�lido - C�pia")
	lRetOk := .F.
Endif

Return(lRetOk)

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    � PedcPdf  �  Autor � F�brica ERPBR   � Data  � 19/04/2023   ���
��+----------+------------------------------------------------------------���
���Descricao � Executa o envio do e-mail.								  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo INTRALOX 										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function PedcPdf()

U_IPCEXCL(.F.)

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    � SendPedc �  Autor � F�brica ERPBR   � Data  � 19/04/2023   ���
��+----------+------------------------------------------------------------���
���Descricao � Executa o envio do e-mail.								  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo INTRALOX 										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function SendPedc()

Local aArea := GetArea()
Local cAssunto := "Pedido de Compra "+SC7->C7_NUM+" - "+FwSM0Util():GetSM0FullName()
Local aMensage := {}
Local aAttach  := {}
Local zPdf     := SC7->C7_NUM+" "+AllTrim(SA2->A2_NOME)
Local zAttach  := "\U6\"+zPdf+".pdf"

AAdd(aAttach, zAttach)

AAdd(aMensage, "AVISO IMPORTANTE:")
AAdd(aMensage, "As datas informadas no pedido s�o para recebimento na Intralox.")
AAdd(aMensage, "Favor considerar o tempo de transporte para n�o haver dem�ritos em sua efici�ncia de entrega.")
AAdd(aMensage, "A data de entrega dever� ser rigorosamente cumprida, caso n�o consiga cumpri-la, por favor, entre em contato imediatamente informando a nova data a ser considerada.")
AAdd(aMensage, "Se n�o houver qualquer discord�ncia quanto as datas solicitadas entenderemos que o atendimento ser� realizado conforme nossa solicita��o.")
AAdd(aMensage, "OBSERVA��ES IMPORTANTES:")
AAdd(aMensage, "Arquivo XML (obrigat�rio): o envio do arquivo XML e DANFE dever� ser atrav�s do e-mail nfebrasil@intralox.com")
AAdd(aMensage, "No arquivo XML, o n�mero do pedido Intralox dever� constar no campo XPED preenchido com apenas 6 caracteres (2 letras e 4 n�meros), assim como o n�mero do item do pedido que dever� constar no campo NITEMPED preenchido com 4 caracteres (0001, 0002, etc).")
AAdd(aMensage, "Na descri��o do item, dever� constar o nosso c�digo DPP/DPE.")
AAdd(aMensage, "Boleto: o envio dever� ser para o endere�o de e-mail financeirobrasil@intralox.com")
AAdd(aMensage, "Endere�o de Entrega (CIF) *PR�DIO ARB*")
AAdd(aMensage, "Rua Alberto Guizo, 121 - Distrito Industrial Jo�o Narezzi")
AAdd(aMensage, "CEP 13347-402 - Indaiatuba/SP")
AAdd(aMensage, "Contatos:")
AAdd(aMensage, "Compras / D�bora Santana: comprasbrasil@intralox.com - (19) 9 9711-9570")
AAdd(aMensage, "Recebimento / Vit�ria: recebimentobrasil@intralox.com")
AAdd(aMensage, "Hor�rio de Recebimento:")
AAdd(aMensage, "De segunda a quinta das 7h30 �s 11h00 e 13h00 �s 16h30")
AAdd(aMensage, "De sexta das 7h30 �s 11h00 e 13h00 �s 15h30")
AAdd(aMensage, "CONDI��ES COMERCIAIS: VIDE PEDIDO ANEXO (PDF)")

zCopias := ""
If !Empty(cMailRec)
	zCopias += AllTrim(cMailRec)
Endif
If !Empty(cMailPcp)
	zCopias += IIf(!Empty(zCopias),";","") + AllTrim(cMailPcp)
Endif
If !Empty(cMailCop)
	zCopias += IIf(!Empty(zCopias),";","") + AllTrim(cMailCop)
Endif

zEmail  := AllTrim(cMailFor)
zCopOcu := IIf( FWCodEmp() == "U6", "comprasbrasil@intralox.com", "" )
zResult := U_TMAILMNG(zEmail, cAssunto, aMensage, zAttach, zCopias, zCopOcu)

fErase(zAttach)

RestArea(aArea)

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � TMAILMNG �  Autor � Luis Brandini   � Data  � 19/04/2023   ���
��+----------+------------------------------------------------------------���
���Descricao � Objeto para envio de email.								  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo INTRALOX 										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function TMAILMNG(zEmail, zAssunto, aMensage, zAttach, zCopias, zCopOcu)

Local oServer
Local oMessage
Local zSmtp     := Alltrim(GetMv("MV_RELSERV"))
Local nPosPort  := AT(":",zSmtp)
Local zServer	:= Substr(zSmtp, 1, nPosPort-1 )
Local zPorta    := Val(Substr(zSmtp, nPosPort+1, Len(zSmtp)-nPosPort))
Local zAccount  := Alltrim(GetMv("MV_RELACNT"))
Local zPassword := Alltrim(GetMv("MV_RELAPSW"))
Local zEmlFrom  := Alltrim(GetMv("MV_RELFROM"))
Local lAuth     := GetMv("MV_RELAUTH")
Local lSSL      := GetMv("MV_RELSSL")
Local lTLS      := GetMv("MV_RELTLS")
Local zResult   := "E-mail enviado com sucesso."
Local zBody     := ""
Local zMsgFim   := "Por favor n�o responda essa mensagem. Esse � um e-mail autom�tico."
Local nInd

If !(FWCodEmp() $("99,U6"))
	MsgAlert("Empresa n�o autorizada: "+FWCodEmp())
	Return
Endif

zBody += '<DIV><FONT face=Arial size=2><IMG alt="" hspace=0 border=0></FONT></DIV>'
zBody += '<DIV><FONT face=Arial size=2></FONT>&nbsp;</DIV>'
zBody += '<DIV><SPAN class=610203920-12022004><FONT face=Verdana color=#ff0000 '
zBody += 'size=3><STRONG>'+FwSM0Util():GetSM0FullName()+'</STRONG></FONT></SPAN></DIV><hr>'
For nInd := 1 to Len(aMensage)
	If nInd == 1 .Or. nInd == 6
		If nInd == 6
			zBody += '<p>'
		Endif
		zBody += '<DIV><FONT face=Verdana color=#000080 size=2><STRONG>' + aMensage[nInd] + '</STRONG></FONT></DIV>'
	Else
		zBody += '<DIV><FONT face=Verdana color=#000080 size=2><SPAN class=216593018-10022004>' + aMensage[nInd] + '</SPAN></FONT></DIV>'
	Endif	
Next nInd
zBody += '<p>'
zBody += '<DIV><FONT face=Verdana color=#ff0000 size=2><SPAN class=216593018-10022004>' + zMsgFim + '</SPAN></FONT></DIV><p>'

oMessage := TMailMessage():New()

oMessage:Clear()

oMessage:cFrom    := zEmlFrom
oMessage:cTo      := zEmail
oMessage:cCc      := zCopias
oMessage:cBcc     := zCopOcu
oMessage:cSubject := zAssunto
oMessage:cBody    := zBody

If oMessage:AttachFile(zAttach) < 0
	zMsgRet := "Erro ao atachar o arquivo."
	MsgAlert(zMsgRet)
	zResult := zMsgRet
	Return(zResult)
Endif

oServer := TMailManager():New()

If lSSL
	oServer:SetUseSSL(.T.)
Endif	

If lTLS
	oServer:SetUseTLS(.T.)
Endif	
  
oServer:Init("", zServer, zAccount, zPassword, 0, zPorta)

zRet := oServer:SetSmtpTimeOut(60)
If zRet != 0
	zMsgRet := "Falha ao setar o time out: "+oServer:GetErrorString(zRet)
	MsgAlert(zMsgRet)
	zResult := zMsgRet
	Return(zResult)
Endif

zRet := oServer:SmtpConnect()
If zRet != 0
	zMsgRet := "Falha ao conectar no servidor de email: "+oServer:GetErrorString(zRet)
	MsgAlert(zMsgRet)
	zResult := zMsgRet
	Return(zResult)
Endif

If lAuth
	zRet := oServer:SmtpAuth(zAccount, zPassword)
	If zRet != 0
		zMsgRet := "Falha na autentica��o do servidor smtp: "+oServer:GetErrorString(zRet)
		MsgAlert(zMsgRet)
		zResult := zMsgRet
		Return(zResult)
	Endif
Endif

zRet := oMessage:Send(oServer)
If zRet != 0
    zMsgRet := "Erro ao enviar o e-mail: "+oServer:GetErrorString(zRet)
	MsgAlert(zMsgRet)
	zResult := zMsgRet
	Return(zResult)
Endif
   
zRet := oServer:SmtpDisconnect()
If zRet != 0
	zMsgRet := "Erro ao desconectar do servidor smtp: "+oServer:GetErrorString(zRet)
	MsgAlert(zMsgRet)
	zResult := zMsgRet
	Return(zResult)
Endif

MsgAlert(zResult)

Return(zResult)

#include "protheus.ch"
#Include "topconn.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � IPCEXCL  � Autor �  F�brica ERP.BR   � Data �  18/04/2023  ���
��+----------+------------------------------------------------------------���
���Descricao � Chamada exclusiva para impress�o do pedido de compra       ���
���          � modelo espec�fico com extens�o Pdf.				  		  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo INTRALOX 										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function IPCEXCL(lOpen)

Local aPedido := {}
Local cPath   := "c:\report"
Local lExibe  := IIf(lOpen==Nil,.T.,lOpen)

If !(FWCodEmp() $("99,U6"))
	MsgAlert("Empresa n�o autorizada: "+FWCodEmp())
	Return
Endif

If !ExistDir(cPath)
	MakeDir(cPath)
EndIf

cQuery := " SELECT * "
cQuery += " FROM "+RetSqlName("SC7")
cQuery += " WHERE C7_FILIAL = '"+xFilial("SC7")+"' "
cQuery += " AND C7_NUM = '"+SC7->C7_NUM+"' "
cQuery += " AND C7_RESIDUO = ' ' "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY C7_FILIAL, C7_NUM, C7_ITEM "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL7", .F., .T.)

DbSelectArea("SQL7")
SQL7->(DbGotop())
While !Eof()
	AAdd(aPedido,{SQL7->C7_FILIAL, SQL7->C7_NUM, SQL7->C7_ITEM })
	SQL7->(DbSkip())
Enddo
SQL7->(DbCloseArea())

If Len(aPedido) > 0
	U_PDFPEDC(aPedido, cPath, lExibe)
Else
	MsgAlert("Pedido n�o dispon�vel para impress�o.")
Endif

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � IPCCALL  � Autor �  F�brica ERP.BR   � Data �  18/04/2023  ���
��+----------+------------------------------------------------------------���
���Descricao � Interface de processamento para gera��o dos pedidos de     ���
���          � compra modelo espec�fico com extens�o Pdf.				  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo INTRALOX 										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function IPCCALL()

Local cPerg	:= Padr("IPCCALL",10)

If Pergunte(cPerg,.T.)
	Preparar()
Endif

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    � Preparar  � Autor � Fabrica ERPBR    � Data � 18/04/2023	  ���
��+-----------------------------------------------------------------------+��
���Descri��o � Prepara o processamento principal.						  ���
��+-----------------------------------------------------------------------+��
S���Uso       � Exclusivo INTRALOX										  ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function Preparar()

Private cEOL    := CHR(13)+CHR(10)
Private zDirPdf := AllTrim(mv_par05)

If Empty(mv_par05)
	MsgInfo("Aten��o, diret�rio Pdf n�o informado. Verifique os par�metros.")
	Return
Endif

If !File(zDirPdf+"\*.*")
	MsgInfo("Aten��o, diret�rio Pdf inv�lido."+cEOL+;
			zDirPdf+cEOL+;
			"Verifique os par�metros.")
	Return
Endif

MsgRun("Aguarde, gerando ordens de compra Pdf...","Processando",{|| ProcImp() })

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    � ProcImp  � Autor  � Fabrica ERPBR     � Data � 18/04/2023  ���
��+-----------------------------------------------------------------------+��
���Descri��o � Processamento da importa��o.								  ���
��+-----------------------------------------------------------------------+��
���Uso       � Exclusivo INTRALOX										  ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function ProcImp()

Local nTotSql  := 0
Local zPedAnt  := ""
Local lKeyPed  := .F.
Local aPedido  := {}

cQuery := " SELECT COUNT(*)AS SOMA "
cQuery += " FROM "+RetSqlName("SC7")
cQuery += " WHERE C7_FILIAL = '"+xFilial("SC7")+"' "
If !Empty(mv_par01)
	cQuery += " AND C7_NUM = '"+mv_par01+"' "
Endif	
If !Empty(mv_par02)
	cQuery += " AND C7_FORNECE = '"+mv_par02+"' "
Endif
cQuery += " AND C7_EMISSAO BETWEEN '"+DtoS(mv_par03)+"' AND '"+DtoS(mv_par04)+ "' "
cQuery += " AND C7_CONAPRO = 'L' "
cQuery += " AND C7_RESIDUO = ' ' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL7", .F., .T.)
nTotSql := SQL7->SOMA
SQL7->(DbCloseArea())

If nTotSql == 0
	MsgAlert("Sem dados para processamento. Verifique os par�metros.")
	Return
Endif

cQuery := " SELECT * "
cQuery += " FROM "+RetSqlName("SC7")
cQuery += " WHERE C7_FILIAL = '"+xFilial("SC7")+"' "
If !Empty(mv_par01)
	cQuery += " AND C7_NUM = '"+mv_par01+"' "
Endif	
If !Empty(mv_par02)
	cQuery += " AND C7_FORNECE = '"+mv_par02+"' "
Endif
cQuery += " AND C7_EMISSAO BETWEEN '"+DtoS(mv_par03)+"' AND '"+DtoS(mv_par04)+ "' "
cQuery += " AND C7_CONAPRO = 'L' "
cQuery += " AND C7_RESIDUO = ' ' "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY C7_FILIAL, C7_NUM, C7_ITEM "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL7", .F., .T.)

DbSelectArea("SQL7")
SQL7->(DbGotop())
While !Eof()

	If SQL7->(C7_FILIAL+C7_NUM) != zPedAnt
		If lKeyPed
			U_PDFPEDC(aPedido, mv_par05, (mv_par06==1))
			aPedido := {}
		Else
			lKeyPed := .T.
		Endif
		zPedAnt := SQL7->(C7_FILIAL+C7_NUM)
	Endif

	AAdd(aPedido,{SQL7->C7_FILIAL, SQL7->C7_NUM, SQL7->C7_ITEM})

	DbSelectArea("SQL7")
	SQL7->(DbSkip())
	If Eof()
		U_PDFPEDC(aPedido, mv_par05, (mv_par06==1))
	Endif

	DbSelectArea("SQL7")
Enddo
SQL7->(DbCloseArea())

Return

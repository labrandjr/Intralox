#include "protheus.ch"
#include "totvs.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ U6PCP001  ¦ Autor ¦ Fábrica ERPBR   ¦   Data   ¦ Abr/2023  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Executa o apontamento de produção automático.			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo INTRALOX 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function U6PCP001()

Local nOpc410 := 0
Local bActOk  := {|| nOpc410:=1,oDlg410:End()}
Local bActCan := {|| nOpc410:=0,oDlg410:End()}
Local bOk410  := {|| IIf( MsgYesNo("Confirma apontamento?","Confirmar"), Eval(bActOk), .F.) }
Local bCan410 := {|| IIf( MsgYesNo("Abandona operação?","Sair"), Eval(bActCan), .F.) }

Private oOk := LoadBitmap( GetResources(), "LBOK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )
Private oDlg410
Private oFnt1,oFnt2,oFnt3,oFnt4,oFntM

Private cNumOpr := Space(6)
Private cDesPro := Space(100)
Private oSayCod,oSayNom,oSayNew

oFnt1 := TFont():New("Tahoma",,23,,.T.)
oFnt2 := TFont():New("Tahoma",,12,,.T.)
oFnt3 := TFont():New("Tahoma",,14,,.F.)
oFnt4 := TFont():New("Tahoma",,11,,.T.)
oFntM := TFont():New("Tahoma",,11,,.F.)

nDlg1 := 001
nDlg2 := 001
nDlg3 := 210
nDlg4 := 750

oDlg410 := MsDialog():New(nDlg1,nDlg2,nDlg3,nDlg4,"Apontamento de PI",,,,,CLR_BLACK,CLR_WHITE,,,.T.)

@ 060,005 SAY "Ordem de Produção" OF oDlg410 PIXEL SIZE 055,009
@ 059,060 MSGET oNumOpr VAR cNumOpr SIZE 060,010 OF oDlg410 PIXEL PICTURE "@!" F3 "SC2" VALID VldOpr()
@ 059,120 TO 071,350 LABEL "" OF oDlg410 PIXEL
oSayNew:= TSay():New(062,125,{||""},oDlg410,,oFnt2,,,,.T.,CLR_BLACK,CLR_WHITE,200,020)
oSayNew:SetText( AllTrim(cDesPro) )
oSayNew:CtrlRefresh()

oDlg410:Activate(,,,.T.,{|| ValidOpr() },,{|| EnchoiceBar(oDlg410,bOk410,bCan410) } )

If nOpc410 == 1
	MsgRun("Aguarde, executando apontamento de produção...","Processando",{|| ExecApont(cNumOpr) })
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ExecApont ¦ Autor ¦ Fábrica ERPBR   ¦   Data   ¦ Abr/2023  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Executa apontamento de produção dos PI´s.				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo INTRALOX 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ExecApont(cNumOpr)

Local nOpc   := 3
Local cTMov  := AllTrim(SuperGetMv("MV_ZZTMPR0",.F.,"010"))
Local aVetor := {}
Local lFalha := .F.
Local dData

Private lMsErroAuto := .F.

cQuery := " SELECT R_E_C_N_O_ AS RECSC2 "
cQuery += " FROM "+RetSqlName("SC2")
cQuery += " WHERE C2_FILIAL = '"+xFilial("SC2")+"' "
cQuery += " AND C2_NUM = '"+cNumOpr+"' "
cQuery += " AND C2_SEQUEN <> '001' "
cQuery += " AND C2_SEQPAI <> ' ' "
cQuery += " AND C2_QUJE = 0 "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY C2_FILIAL, C2_NUM, C2_ITEM, C2_SEQUEN DESC "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQL2", .F., .T.)

DbSelectArea("SQL2")
SQL2->(DbGotop())
While !Eof()

	DbSelectArea("SC2")		
	DbGoto(SQL2->RECSC2)

	aVetor := {}
	dData  := dDataBase
	zDocum := GetSxeNum("SD3","D3_DOC")

	aVetor := { {"D3_OP"     , SC2->(C2_NUM+C2_ITEM+C2_SEQUEN), Nil},;
				{"D3_TM"     , cTMov, Nil},;
				{"D3_COD"    , SC2->C2_PRODUTO, Nil},;
				{"D3_EMISSAO", dData, Nil},; 
				{"D3_DOC"    , zDocum, Nil},; 
				{"D3_QUANT"  , SC2->C2_QUANT, Nil},; 
				{"D3_PARCTOT", "T", Nil},;
				{"D3_QTMAIOR", 0, Nil} }

	MsExecAuto({|x,y| MATA250(x,y)}, aVetor, nOpc)
	If lMsErroAuto
		MsgAlert("Não foi possível apontar a OP "+SC2->(C2_NUM+C2_ITEM+C2_SEQUEN))
		MostraErro()
		lFalha := .T.
		If MsgYesNo("Abandona o processo ?")
			Exit
		Endif
	Else
		ConOut("Sucesso: "+SC2->(C2_NUM+C2_ITEM+C2_SEQUEN))
	Endif
	
	DbSelectArea("SQL2")
	SQL2->(DbSkip())
Enddo
SQL2->(DbCloseArea())

If lFalha
	MsgInfo("Processamento concluído com falhas.")
Else
	MsgInfo("Processamento concluído com sucesso !")
Endif	

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ VldFor    ¦ Autor ¦  Fabrica ERPBR ¦  Data  ¦ 17/04/2023   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Validação do Fornecedor.		 							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo INTRALOX.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function VldOpr()

Local lRetorno := .F.

If Empty(cNumOpr)
	oSayNew:SetText( "" )
	oSayNew:CtrlRefresh()
	lRetorno := .T.
	Return
Endif

DbSelectArea("SC2")
DbSetOrder(1)
If DbSeek( xFilial("SC2") + cNumOpr )
	If SC2->(C2_QUANT-C2_QUJE) <= 0
		MsgAlert("Ordem de Produção (PA) sem saldo em aberto.")
		lRetorno := .F.
	Else
		lRetorno := .T.
	Endif	
Else
	MsgAlert("OP não cadastrada.")
	lRetorno := .F.
Endif

If lRetorno
	cDesPro := AllTrim(SC2->C2_PRODUTO)+" - "+AllTrim(Posicione("SB1",1,xFilial("SB1")+SC2->C2_PRODUTO,"B1_DESC"))
	oSayNew:SetText( AllTrim(cDesPro) )
	oSayNew:CtrlRefresh()
Else
	oSayNew:SetText( "" )
	oSayNew:CtrlRefresh()
Endif

Return(lRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ValidOpr   ¦ Autor ¦ Fabrica ERPBR    ¦ Data ¦ 17/04/2023  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Validação da Ordem de Produção.							  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo INTRALOX.										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ValidOpr()

Local lRet := .T.

If Empty(cNumOpr)
	MsgAlert("Ordem de Produção não informada.")
	lRet := .F.
Endif

If lRet
Endif

Return(lRet)

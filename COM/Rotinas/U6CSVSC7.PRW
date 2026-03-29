#include "protheus.ch"
#include "topconn.ch"
#include "rwmake.ch"
#include "tbiconn.ch"
#include "tbicode.ch"

/*/
{Protheus.doc}
@function: U6CSVSC7
@descrip: Importa Pedido de Compras a partir de arquivo CSV com leiaute definido
@
@type: function
@author: Fábrica ERP.BR
@since: 11/02/2026
@version: P12
@database: MSSQL
/*/
User Function U6CSVSC7()

Local nOpc410 := 0
Local bActOk  := {|| nOpc410:=1,oDlg410:End()}
Local bActCan := {|| nOpc410:=0,oDlg410:End()}
Local bOk410  := {|| IIf( MsgYesNo("Confirma execução?","Confirmar"), Eval(bActOk), .F.) }
Local bCan410 := {|| IIf( MsgYesNo("Abandona execução?","Sair"), Eval(bActCan), .F.) }
Local nRadio1 := 1

Local cArqCsv := Space(200)
Local aLinhOk := {}
Local oGetRat

Private oOk := LoadBitmap( GetResources(), "LBOK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )
Private oDlg410, oRadio1, oTemp1
Private aArqLog := {}

nDlg1 := 001
nDlg2 := 001
nDlg3 := 250
nDlg4 := 700

oDlg410 := MsDialog():New(nDlg1,nDlg2,nDlg3,nDlg4,"Importa Pedido de Compras",,,,,,,,,.T.)

@ 042,005 RADIO oRadio1 VAR nRadio1 3D SIZE 070,010 PROMPT "Simulação","Execução" OF oDlg410 PIXEL

@ 070,020 SAY "Arquivo:" OF oDlg410 PIXEL SIZE 055,009
oGetRat:= TGet():New(068,050,{|u| if(PCount()>0,cArqCsv:=u,cArqCsv)},oDlg410,240,010,"@X",{|o|},,,,,,.T.,,, {|| .T. } ,,,,,,,"cArqCsv")
oTButton := TButton():New(068,300,"...",oDlg410,{||AbreArq(@cArqCsv,oGetRat)},020,010,,,.F.,.T.,.F.,,.F.,,,.F.)

oDlg410:Activate(,,,.T.,{|| ValidLib(cArqCsv,@aLinhOk,nRadio1) },,{|| EnchoiceBar(oDlg410,bOk410,bCan410) } )

If nOpc410 == 1
	If nRadio1 == 1
		FwMsgRun(, { || ProcImpSc7(nRadio1,aLinhOk) },,"Aguarde, simulando a importação")
	Else
		FwMsgRun(, { || ProcImpSc7(nRadio1,aLinhOk) },,"Aguarde, executando a importação")
	Endif
	MsgInfo("Processo concluído.","Aviso")
Endif

Return

/*/
{Protheus.doc}
@function: AbreArq
@descrip: Interface para usuário selecionar o arquivo
@
@type: function
@author: Fábrica ERP.BR
@since: 11/02/2026
@version: P12
@database: MSSQL
/*/
Static Function AbreArq(cGet,oGet)

Local cTitle	   := "Selecionar arquivo"
Local cFile 	   := "Arq.csv  | *.csv"
Local nDefaultMask := 1
Local cDefaultDir  := "C:\"
Local nOptions	   := GETF_LOCALHARD + GETF_LOCALFLOPPY
Local cRet		   := ""

cRet := cGetFile(cFile,cTitle,nDefaultMask,cDefaultDir,.T.,nOptions,.F.)

If !Empty(cRet)
	cGet := cRet
Endif

oGet:Refresh()

Return

/*/
{Protheus.doc}
@function: ValidLib
@descrip: Valida o formulário
@
@type: function
@author: Fábrica ERP.BR
@since: 11/02/2026
@version: P12
@database: MSSQL
/*/
Static Function ValidLib(cArqCsv,aLinhOk,nRadio1)

Local lRet := .T.
Local oArquivo := FWFileReader():New(cArqCsv)
Local aLinha   := {}
Local cLinha   := ""
Local nLinha   := 0
Local lTamLin  := .T.
Local cEOL     := CHR(13)+CHR(10)
Local aArqCsv  := {}
Local lin

If lRet
	If Empty(cArqCsv)
		MsgAlert("Arquivo nao informado.")
		lRet := .F.
	Else
		If !File(cArqCsv)
			MsgAlert("Arquivo invalido ou nao localizado.")
			lRet := .F.
		Else
			oArquivo := FWFileReader():New(cArqCsv)
			If oArquivo:Open()
				While oArquivo:HasLine()
					nLinha++
					cLinha := oArquivo:GetLine()
					cLinha := Upper(cLinha)
					cLinha := NoAcento(cLinha)
					aLinha := StrTokArr2(cLinha,";",.T.)
					If Len(aLinha) <> 12
						MsgAlert("Tamanho da linha invalido: "+AllTrim(STR(Len(aLinha)))+" posicoes."+cEOL+"O leiaute deve ter 12 posicoes.")
						lTamLin := .F.
						Exit
					Endif
					//
					AAdd(aArqCsv,{ AllTrim(aLinha[1]),;  // Número da SC
								   AllTrim(aLinha[2]),;  // Item da SC
								   AllTrim(aLinha[3]),;  // Código do Fornecedor
								   AllTrim(aLinha[4]),;  // Loja do Fornecedor
								   AllTrim(aLinha[5]),;  // Quantidade
								   AllTrim(aLinha[6]),;  // Preço
								   AllTrim(aLinha[7]),;  // Alíquota IPI
								   AllTrim(aLinha[8]),;  // Alíquota ICMS
								   AllTrim(aLinha[9]),;  // Valor do Desconto
								   AllTrim(aLinha[10]),; // Data de Entrega
								   AllTrim(aLinha[11]),; // Tipo de Frete
								   AllTrim(aLinha[12])}) // Cond.Pagamento
					//
				Enddo
				oArquivo:Close()
			Else
				MsgAlert("Erro ao abrir o arquivo: "+cArqCsv)
				lRet := .F.
			Endif
		Endif
	Endif
Endif

If !lTamLin
	lRet := .F.
Endif

If lRet
	If Len(aArqCsv) > 0
		
		For lin := 1 to Len(aArqCsv)

			aLinha  := {}
			xSeqLin := StrZero(lin,5)
			xNumSol := PadR(aArqCsv[lin][1],TamSx3("C1_NUM")[1])
			xItemSc := PadR(aArqCsv[lin][2],TamSx3("C1_ITEM")[1])
			xCodFor := PadR(aArqCsv[lin][3],TamSx3("C7_FORNECE")[1])
			xLojFor := PadR(aArqCsv[lin][4],TamSx3("C7_LOJA")[1])
			xQuantd := StrTran(aArqCsv[lin][5],".","")
			xQuantd := StrTran(xQuantd,",",".")
			xQuantd := Val(xQuantd)
			xPrcUni := StrTran(aArqCsv[lin][6],".","")
			xPrcUni := StrTran(xPrcUni,",",".")
			xPrcUni := Val(xPrcUni)
			xAlqIpi := StrTran(aArqCsv[lin][7],".","")
			xAlqIpi := StrTran(xAlqIpi,",",".")
			xAlqIpi := Val(xAlqIpi)
			xAlqIcm := StrTran(aArqCsv[lin][8],".","")
			xAlqIcm := StrTran(xAlqIcm,",",".")
			xAlqIcm := Val(xAlqIcm)
			xVlDesc := StrTran(aArqCsv[lin][9],".","")
			xVlDesc := StrTran(xVlDesc,",",".")
			xVlDesc := Val(xVlDesc)
			xDtEntr := CtoD(aArqCsv[lin][10])
			xTpFret := AllTrim(aArqCsv[lin][11])
			xCondPg := PadR(aArqCsv[lin][12],TamSx3("C7_COND")[1])

			AAdd(aLinha,xSeqLin)
			AAdd(aLinha,xNumSol)
			AAdd(aLinha,xItemSc)
			AAdd(aLinha,xCodFor)
			AAdd(aLinha,xLojFor)
			AAdd(aLinha,xQuantd)
			AAdd(aLinha,xPrcUni)
			AAdd(aLinha,xAlqIpi)
			AAdd(aLinha,xAlqIcm)
			AAdd(aLinha,xVlDesc)
			AAdd(aLinha,xDtEntr)
			AAdd(aLinha,xTpFret)
			AAdd(aLinha,xCondPg)

			DbSelectArea("SC1")
			DbSetOrder(1)
			If !DbSeek( xFilial("SC1") + xNumSol + xItemSc )
				GravaLog(aLinha,"SOLICIT.COMPRA NAO LOCALIZADA",.T.)
				Loop
			Else
				If !Empty(SC1->C1_RESIDUO)
					GravaLog(aLinha,"SOLICIT.COMPRA SEM SALDO RESIDUAL",.T.)
					Loop
				ElseIf SC1->(C1_QUANT - C1_QUJE) < xQuantd
					GravaLog(aLinha,"SOLICIT.COMPRA SEM SALDO DISPONIVEL ("+AllTrim(STR(SC1->(C1_QUANT - C1_QUJE)))+")",.T.)
					Loop
				Endif
			Endif

			DbSelectArea("SA2")
			DbSetOrder(1)
			If !DbSeek( xFilial("SA2") + xCodFor + xLojFor )
				GravaLog(aLinha,"FORNECEDOR NAO LOCALIZADO",.T.)
				Loop
			Else
				If SA2->A2_MSBLQL == "1"
					GravaLog(aLinha,"FORNECEDOR BLOQUEADO",.T.)
					Loop
				Endif
			Endif

			If xQuantd <= 0
				GravaLog(aLinha,"QUANTIDADE NAO INFORMADA",.T.)
				Loop
			Endif

			If xPrcUni <= 0
				GravaLog(aLinha,"PRECO UNITARIO NAO INFORMADO",.T.)
				Loop
			Endif

			If xVlDesc > (xQuantd * xPrcUni)
				GravaLog(aLinha,"VALOR DO DESCONTO INVALIDO",.T.)
				Loop
			Endif

			If xDtEntr < Date()
				GravaLog(aLinha,"DATA DE ENTREGA VENCIDA",.T.)
				Loop
			Endif

			If !(xTpFret $("C,F"))
				GravaLog(aLinha,"TIPO DE FRETE INVALIDO",.T.)
				Loop
			Endif

			DbSelectArea("SE4")
			DbSetOrder(1)
			If !DbSeek( xFilial("SE4") + xCondPg )
				GravaLog(aLinha,"COND.PAGAMENTO NAO LOCALIZADA",.T.)
				Loop
			Else
				If SA2->A2_MSBLQL == "1"
					GravaLog(aLinha,"COND.PAGAMENTO BLOQUEADA",.T.)
					Loop
				Endif
			Endif

			AAdd(aLinha,xSeqLin)
			AAdd(aLinha,xNumSol)
			AAdd(aLinha,xItemSc)
			AAdd(aLinha,xCodFor)
			AAdd(aLinha,xLojFor)
			AAdd(aLinha,xQuantd)
			AAdd(aLinha,xPrcUni)
			AAdd(aLinha,xAlqIpi)
			AAdd(aLinha,xAlqIcm)
			AAdd(aLinha,xVlDesc)
			AAdd(aLinha,xDtEntr)
			AAdd(aLinha,xTpFret)
			AAdd(aLinha,xCondPg)

			AAdd(aLinhOk,{ xSeqLin, xNumSol, xItemSc, xCodFor, xLojFor, xQuantd, xPrcUni, xAlqIpi, xAlqIcm, xVlDesc, xDtEntr, xTpFret, xCondPg })

		Next lin
	Endif
Endif

Return(lRet)

/*/
{Protheus.doc}
@function: GravaLog
@descrip: Grava log de erro
@
@type: function
@author: Fábrica ERP.BR
@since: 11/02/2026
@version: P12
@database: MSSQL
/*/
Static Function GravaLog(aLinha,cMsgErro,lErro)

AAdd(aArqLog,{ AllTrim(aLinha[1]),; // LOG->LOG_SEQ
			   AllTrim(aLinha[2]),; // LOG->LOG_SOL
			   AllTrim(aLinha[3]),; // LOG->LOG_ITE
			   AllTrim(aLinha[4]),; // LOG->LOG_FOR
			   AllTrim(aLinha[5]),; // LOG->LOG_LOJ
			   aLinha[6],; // LOG->LOG_QTD
			   aLinha[7],; // LOG->LOG_PRC
			   aLinha[8],; // LOG->LOG_IPI
			   aLinha[9],; // LOG->LOG_ICM
			   aLinha[10],; // LOG->LOG_DES
			   aLinha[11],; // LOG->LOG_ENT
			   AllTrim(aLinha[12]),; // LOG->LOG_FRE
			   AllTrim(aLinha[13]),; // LOG->LOG_CPG
			   IIf(lErro,"Sim","Não"),; // LOG->LOG_ERR
			   AllTrim(cMsgErro) }) // LOG->LOG_MSG

Return

/*/
{Protheus.doc}
@function: ProcImpSc7
@descrip: Executa o processamento
@
@type: function
@author: Fábrica ERP.BR
@since: 11/02/2026
@version: P12
@database: MSSQL
/*/
Static Function ProcImpSc7(nRadio1,aLinhOk)

Local aCabec := {}
Local aItem  := {}
Local aItens := {}
Local lCabec := .F.
Local csv, log

Private lMsErroAuto    := .F.
Private lMsHelpAuto    := .T.
Private lAutoErrNoFile := .T.

For csv := 1 to Len(aLinhOk)

	xSeqLin := aLinhOk[csv][1]
	xNumSol := aLinhOk[csv][2]
	xItemSc := aLinhOk[csv][3]
	xFornec := aLinhOk[csv][4]
	xLojFor := aLinhOk[csv][5]
	xQuantd := aLinhOk[csv][6]
	xPrcUni := aLinhOk[csv][7]
	xAlqIpi := aLinhOk[csv][8]
	xAlqIcm := aLinhOk[csv][9]
	xVlDesc := aLinhOk[csv][10]
	xDtEntr := aLinhOk[csv][11]
	xTpFret := aLinhOk[csv][12]
	xCondPg := aLinhOk[csv][13]

	If nRadio1 == 1 // Simulação

		AAdd(aArqLog,{ xSeqLin,; // LOG->LOG_SEQ
					   AllTrim(xNumSol),; // LOG->LOG_SOL
					   AllTrim(xItemSc),; // LOG->LOG_ITE
					   AllTrim(xFornec),; // LOG->LOG_FOR
					   AllTrim(xLojFor),; // LOG->LOG_LOJ
					   xQuantd,; // LOG->LOG_QTD
					   xPrcUni,; // LOG->LOG_PRC
					   xAlqIpi,; // LOG->LOG_IPI
					   xAlqIcm,; // LOG->LOG_ICM
					   xVlDesc,; // LOG->LOG_DES
					   xDtEntr,; // LOG->LOG_ENT
					   AllTrim(xTpFret),; // LOG->LOG_FRE
					   AllTrim(xCondPg),; // LOG->LOG_CPG
					   "Não",; // LOG->LOG_ERR
					   "SIMULAÇÃO VALIDADA" }) // LOG->LOG_MSG

	ElseIf nRadio1 == 2 // Execução

		DbSelectArea("SA2")
		DbSetOrder(1)
		DbSeek( xFilial("SA2") + xFornec + xLojFor )

		DbSelectArea("SE4")
		DbSetOrder(1)
		DbSeek( xFilial("SE4") + xCondPg )

		If !lCabec
			lCabec := .T.
			cNumPC := GetNumSC7()
			AAdd(aCabec,{ "C7_NUM"    , cNumPC         , Nil })
			AAdd(aCabec,{ "C7_EMISSAO", Date()         , Nil })
			AAdd(aCabec,{ "C7_FORNECE", SA2->A2_COD    , Nil })
			AAdd(aCabec,{ "C7_LOJA"   , SA2->A2_LOJA   , Nil })
			AAdd(aCabec,{ "C7_COND"   , SE4->E4_CODIGO , Nil })
			AAdd(aCabec,{ "C7_CONTATO", SA2->A2_CONTATO, Nil })
			AAdd(aCabec,{ "C7_FILENT" , cFilAnt        , Nil })			
			AAdd(aCabec,{ "C7_USER"   , __cUserId      , Nil })			
		Endif

		DbSelectArea("SC1")
		DbSetOrder(1)
		DbSeek( xFilial("SC1") + xNumSol + xItemSc )

		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek( xFilial("SB1") + SC1->C1_PRODUTO )

		xVlrTot := xQuantd * xPrcUni

		aItem := {}
		AAdd(aItem,{ "C7_PRODUTO", SB1->B1_COD    , Nil })
		AAdd(aItem,{ "C7_QUANT"  , xQuantd        , Nil })
		AAdd(aItem,{ "C7_PRECO"  , xPrcUni        , Nil })
		AAdd(aItem,{ "C7_TOTAL"  , xVlrTot        , Nil })
		AAdd(aItem,{ "C7_DATPRF" , xDtEntr        , Nil })
		AAdd(aItem,{ "C7_LOCAL"  , SB1->B1_LOCPAD , Nil })
		AAdd(aItem,{ "C7_DESCRI" , SB1->B1_DESC   , Nil })
		AAdd(aItem,{ "C7_IPI"    , xAlqIpi        , Nil })
		AAdd(aItem,{ "C7_PICM"   , xAlqIcm        , Nil })
		AAdd(aItem,{ "C7_VLDESC" , xVlDesc        , Nil })
		AAdd(aItem,{ "C7_TPFRETE", xTpFret        , Nil })
		AAdd(aItem,{ "C7_NUMSC"  , xNumSol        , Nil })
		AAdd(aItem,{ "C7_ITEMSC" , xItemSc        , Nil })
		AAdd(aItem,{ "C7_QTDSOL" , xQuantd        , Nil })
		AAdd(aItens, aItem)

		AAdd(aArqLog,{ xSeqLin,; // LOG->LOG_SEQ
					   AllTrim(xNumSol),; // LOG->LOG_SOL
					   AllTrim(xItemSc),; // LOG->LOG_ITE
					   AllTrim(xFornec),; // LOG->LOG_FOR
					   AllTrim(xLojFor),; // LOG->LOG_LOJ
					   xQuantd,; // LOG->LOG_QTD
					   xPrcUni,; // LOG->LOG_PRC
					   xAlqIpi,; // LOG->LOG_IPI
					   xAlqIcm,; // LOG->LOG_ICM
					   xVlDesc,; // LOG->LOG_DES
					   xDtEntr,; // LOG->LOG_ENT
					   AllTrim(xTpFret),; // LOG->LOG_FRE
					   AllTrim(xCondPg),; // LOG->LOG_CPG
					   "Não",; // LOG->LOG_ERR
					   "ITEM INCLUIDO NO PEDIDO" }) // LOG->LOG_MSG

		If csv == Len(aLinhOk)

			lMsErroAuto    := .F.
			lMsHelpAuto    := .T.
			lAutoErrNoFile := .T.
			MsExecAuto({|x,y,z,w| MATA120(x,y,z,w)},1, aCabec, aItens, 3)

			If !lMsErroAuto

				AAdd(aArqLog,{ "99999",; // LOG->LOG_SEQ
							"",; // LOG->LOG_SOL
							"",; // LOG->LOG_ITE
							AllTrim(xFornec),; // LOG->LOG_FOR
							AllTrim(xLojFor),; // LOG->LOG_LOJ
							0,; // LOG->LOG_QTD
							0,; // LOG->LOG_PRC
							0,; // LOG->LOG_IPI
							0,; // LOG->LOG_ICM
							0,; // LOG->LOG_DES
							CtoD(""),; // LOG->LOG_ENT
							"",; // LOG->LOG_FRE
							"",; // LOG->LOG_CPG
							"Não",; // LOG->LOG_ERR
							"PEDIDO "+AllTrim(SC7->C7_NUM)+" CADASTRADO COM SUCESSO" }) // LOG->LOG_MSG

			Else

				aLog := GetAutoGrLog()
				bMsg := ""
				For log := 1 to Len(aLog)
					bMsg += AllTrim(Substr(aLog[log],9))
				Next log

				AAdd(aArqLog,{ "99999",; // LOG->LOG_SEQ
							"",; // LOG->LOG_SOL
							"",; // LOG->LOG_ITE
							AllTrim(xFornec),; // LOG->LOG_FOR
							AllTrim(xLojFor),; // LOG->LOG_LOJ
							0,; // LOG->LOG_QTD
							0,; // LOG->LOG_PRC
							0,; // LOG->LOG_IPI
							0,; // LOG->LOG_ICM
							0,; // LOG->LOG_DES
							CtoD(""),; // LOG->LOG_ENT
							"",; // LOG->LOG_FRE
							"",; // LOG->LOG_CPG
							"Sim",; // LOG->LOG_ERR
							bMsg }) // LOG->LOG_MSG

			Endif

		Endif

	Endif

Next doc

// Cria arquivo temporário
pCriaTemp()

// Carrega arquivo temporário
pLoadTemp()

// Log de Ocorrências
u_LogOcoSc7()

LOG->(DbCloseArea())
oTemp1:Delete()

Return

/*/
{Protheus.doc}
@function: pCriaTemp
@descrip: Cria arquivo temporario Log
@
@type: function
@author: Fábrica ERP.BR
@since: 11/02/2026
@version: P12
@database: MSSQL
/*/
Static Function pCriaTemp()

Local _aTmp1 := {}

oTemp1 := FWTemporaryTable():New("LOG")

AAdd ( _aTmp1, {"LOG_SEQ", "C", 005, 00} )
AAdd ( _aTmp1, {"LOG_SOL", "C", TamSx3("C1_NUM")[1], 00} )
AAdd ( _aTmp1, {"LOG_ITE", "C", TamSx3("C1_ITEM")[1], 00} )
AAdd ( _aTmp1, {"LOG_FOR", "C", TamSx3("C7_FORNECE")[1], 00} )
AAdd ( _aTmp1, {"LOG_LOJ", "C", TamSx3("C7_LOJA")[1], 00} )
AAdd ( _aTmp1, {"LOG_QTD", "N", TamSx3("C7_QUANT")[1], TamSx3("C7_QUANT")[2]} )
AAdd ( _aTmp1, {"LOG_PRC", "N", TamSx3("C7_PRECO")[1], TamSx3("C7_PRECO")[2]} )
AAdd ( _aTmp1, {"LOG_IPI", "N", TamSx3("C7_IPI")[1], TamSx3("C7_IPI")[2]} )
AAdd ( _aTmp1, {"LOG_ICM", "N", TamSx3("C7_PICM")[1], TamSx3("C7_PICM")[2]} )
AAdd ( _aTmp1, {"LOG_DES", "N", TamSx3("C7_VLDESC")[1], TamSx3("C7_VLDESC")[2]} )
AAdd ( _aTmp1, {"LOG_ENT", "D", 008, 00} )
AAdd ( _aTmp1, {"LOG_FRE", "C", 001, 00} )
AAdd ( _aTmp1, {"LOG_CPG", "C", TamSx3("C7_COND")[1], 00} )
AAdd ( _aTmp1, {"LOG_ERR", "C", 003, 00} )
AAdd ( _aTmp1, {"LOG_MSG", "C", 250, 00} )
oTemp1:SetFields( _aTmp1 )
oTemp1:AddIndex("indice1", {"LOG_SEQ"})
oTemp1:Create()

Return

/*/
{Protheus.doc}
@function: pLoadTemp
@descrip: Carrega log de erro
@
@type: function
@author: Fábrica ERP.BR
@since: 11/02/2026
@version: P12
@database: MSSQL
/*/
Static Function pLoadTemp()

Local log

DbSelectArea("LOG")
DbSetOrder(1)

For log := 1 to Len(aArqLog)
	RecLock("LOG",.T.)
	LOG->LOG_SEQ := aArqLog[log][1]
	LOG->LOG_SOL := aArqLog[log][2]
	LOG->LOG_ITE := aArqLog[log][3]
	LOG->LOG_FOR := aArqLog[log][4]
	LOG->LOG_LOJ := aArqLog[log][5]
	LOG->LOG_QTD := aArqLog[log][6]
	LOG->LOG_PRC := aArqLog[log][7]
	LOG->LOG_IPI := aArqLog[log][8]
	LOG->LOG_ICM := aArqLog[log][9]
	LOG->LOG_DES := aArqLog[log][10]
	LOG->LOG_ENT := aArqLog[log][11]
	LOG->LOG_FRE := aArqLog[log][12]
	LOG->LOG_CPG := aArqLog[log][13]
	LOG->LOG_ERR := aArqLog[log][14]
	LOG->LOG_MSG := aArqLog[log][15]
	MsUnLock()
Next log

Return

/*/
{Protheus.doc}
@function: LogOcoSc7
@descrip: Imprime o Log
@
@type: function
@author: Fábrica ERP.BR
@since: 11/02/2026
@version: P12
@database: MSSQL
/*/
User Function LogOcoSc7()

Local oRepLog

oRepLog := LogOcoSc7()

If oRepLog == Nil
	Return
Endif

oRepLog:PrintDialog()

Return

/*/
{Protheus.doc}
@function: LogOcoSc7
@descrip: Executa impressao
@
@type: function
@author: Fábrica ERP.BR
@since: 05/01/2026
@version: P12
@database: MSSQL
/*/
Static Function LogOcoSc7()

Local oRepLog
Local oSection1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oRepLog := TReport():New("LOGPROC","Log de processamento", , {|oRepLog| LogPrint(oRepLog), "Este relatório irá imprimir as ocorrências de processamento."})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da secao utilizada pelo relatorio                               ³
//³                                                                        ³
//³TRSection():New                                                         ³
//³ExpO1 : Objeto TReport que a secao pertence                             ³
//³ExpC2 : Descricao da seçao                                              ³
//³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ³
//³        sera considerada como principal para a seção.                   ³
//³ExpA4 : Array com as Ordens do relatório                                ³
//³ExpL5 : Carrega campos do SX3 como celulas                              ³
//³        Default : False                                                 ³
//³ExpL6 : Carrega ordens do Sindex                                        ³
//³        Default : False                                                 ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1 := TRSection():New(oRepLog,"Log de processamento",{"LOG"},,.F.,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da celulas da secao do relatorio                                ³
//³                                                                        ³
//³TRCell():New                                                            ³
//³ExpO1 : Objeto TSection que a secao pertence                            ³
//³ExpC2 : Nome da celula do relatório. O SX3 será consultado              ³
//³ExpC3 : Nome da tabela de referencia da celula                          ³
//³ExpC4 : Titulo da celula                                                ³
//³        Default : X3Titulo()                                            ³
//³ExpC5 : Picture                                                         ³
//³        Default : X3_PICTURE                                            ³
//³ExpC6 : Tamanho                                                         ³
//³        Default : X3_TAMANHO                                            ³
//³ExpL7 : Informe se o tamanho esta em pixel                              ³
//³        Default : False                                                 ³
//³ExpB8 : Bloco de código para impressao.                                 ³
//³        Default : ExpC2                                                 ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TRCell():New(oSection1, "SEQ", "LOG", "Linha"      , "@!" , 010, , { || LOG->LOG_SEQ } )
TRCell():New(oSection1, "SOL", "LOG", "Num.SC"     , "@!" , 015, , { || LOG->LOG_SOL } )
TRCell():New(oSection1, "ITE", "LOG", "Item SC"    , "@!" , 008, , { || LOG->LOG_ITE } )
TRCell():New(oSection1, "FOR", "LOG", "Fornecedor" , "@!" , 020, , { || LOG->LOG_FOR } )
TRCell():New(oSection1, "LOJ", "LOG", "Loja"       , "@!" , 005, , { || LOG->LOG_LOJ } )
TRCell():New(oSection1, "NOM", "LOG", "Nome"       , "@!" , 100, , { || Posicione("SA2",1,xFilial("SA2")+LOG->LOG_FOR + LOG->LOG_LOJ,"A2_NOME") } )
TRCell():New(oSection1, "PRD", "LOG", "Produto"    , "@!" , 020, , { || Posicione("SC1",1,xFilial("SC1")+LOG->LOG_SOL + LOG->LOG_ITE,"C1_PRODUTO") } )
TRCell():New(oSection1, "DCR", "LOG", "Descrição"  , "@!" , 100, , { || Posicione("SC1",1,xFilial("SC1")+LOG->LOG_SOL + LOG->LOG_ITE,"C1_DESCRI") } )
TRCell():New(oSection1, "QTD", "LOG", "Quantidade" , "@E 9,999,999.9999" , 015, , { || LOG->LOG_QTD } )
TRCell():New(oSection1, "PRC", "LOG", "Preço"      , "@E 999,999.999999" , 015, , { || LOG->LOG_PRC } )
TRCell():New(oSection1, "TOT", "LOG", "Vlr.Total"  , "@E 999,999,999.99" , 015, , { || LOG->(LOG_QTD*LOG_PRC) } )
TRCell():New(oSection1, "IPI", "LOG", "Aliq.IPI"   , "@E 999.99" , 010, , { || LOG->LOG_IPI } )
TRCell():New(oSection1, "ICM", "LOG", "Aliq.ICMS"  , "@E 999.99" , 010, , { || LOG->LOG_ICM } )
TRCell():New(oSection1, "DES", "LOG", "Desconto"   , "@E 999,999,999.99" , 015, , { || LOG->LOG_DES } )
TRCell():New(oSection1, "ENT", "LOG", "Dt.Entrega" , ""   , 010, , { || LOG->LOG_ENT } )
TRCell():New(oSection1, "FRE", "LOG", "Tipo Frete" , "@!" , 010, , { || IIf(LOG->LOG_FRE=="C","CIF","FOB") } )
TRCell():New(oSection1, "CPG", "LOG", "Cond.Pagto.", "@!" , 005, , { || LOG->LOG_CPG } )
TRCell():New(oSection1, "DPG", "LOG", "Descrição"  , "@!" , 100, , { || Posicione("SE4",1,xFilial("SE4")+LOG->LOG_CPG,"E4_DESCRI") } )
TRCell():New(oSection1, "ERR", "LOG", "Erro"       , "@!" , 005, , { || LOG->LOG_ERR } )
TRCell():New(oSection1, "MSG", "LOG", "Ocorrência" , "@!" , 250, , { || LOG->LOG_MSG } )

Return(oRepLog)

/*/
{Protheus.doc}
@function: LogPrint
@descrip: Executa impressao
@
@type: function
@author: Fábrica ERP.BR
@since: 05/01/2026
@version: P12
@database: MSSQL
/*/
Static Function LogPrint(oRepLog)

Local oSection1 := oRepLog:Section(1)

oRepLog:cRealTitle := "Log de processamento"
oRepLog:cTitle := "Log de processamento"

DbSelectArea("LOG")
LOG->(DbGotop())
oRepLog:SetMeter(LOG->(RecCount()))
oSection1:Init()
While !Eof()
	oRepLog:IncMeter()
	oSection1:PrintLine()
	LOG->(DbSkip())
	If Eof()
		oSection1:Finish()
		oRepLog:ThinLine()
	Endif
Enddo

Return

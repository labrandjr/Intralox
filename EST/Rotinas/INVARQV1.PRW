#include "protheus.ch"
#include "topconn.ch"
#include "rwmake.ch"
#include "tbiconn.ch"
#include "tbicode.ch"

/*/
{Protheus.doc}
@function: INVARQV1
@descrip: Importa digitação do inventário a partir de arquivo CSV com leiaute definido
@
@type: function
@author: Fábrica ERP.BR
@since: 01/11/2025
@version: P12
@database: MSSQL
/*/
User Function INVARQV1()

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

oDlg410 := MsDialog():New(nDlg1,nDlg2,nDlg3,nDlg4,"Importa Digitação do Inventário",,,,,,,,,.T.)

@ 042,005 RADIO oRadio1 VAR nRadio1 3D SIZE 070,010 PROMPT "Simulação","Execução" OF oDlg410 PIXEL

@ 070,020 SAY "Arquivo:" OF oDlg410 PIXEL SIZE 055,009
oGetRat:= TGet():New(068,050,{|u| if(PCount()>0,cArqCsv:=u,cArqCsv)},oDlg410,240,010,"@X",{|o|},,,,,,.T.,,, {|| .T. } ,,,,,,,"cArqCsv")
oTButton := TButton():New(068,300,"...",oDlg410,{||AbreArq(@cArqCsv,oGetRat)},020,010,,,.F.,.T.,.F.,,.F.,,,.F.)

oDlg410:Activate(,,,.T.,{|| ValidLib(cArqCsv,@aLinhOk,nRadio1) },,{|| EnchoiceBar(oDlg410,bOk410,bCan410) } )

If nOpc410 == 1
	If nRadio1 == 1
		FwMsgRun(, { || ProcInvArq(nRadio1,aLinhOk) },,"Aguarde, simulando a importação")
	Else
		FwMsgRun(, { || ProcInvArq(nRadio1,aLinhOk) },,"Aguarde, executando a importação")
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
@since: 29/09/2025
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
@since: 29/09/2025
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
					If Len(aLinha) <> 7
						MsgAlert("Tamanho da linha invalido: "+AllTrim(STR(Len(aLinha)))+" posicoes."+cEOL+"O leiaute deve ter 7 posicoes.")
						lTamLin := .F.
						Exit
					Endif
					//
					AAdd(aArqCsv,{ AllTrim(aLinha[1]), AllTrim(aLinha[2]), AllTrim(aLinha[3]), AllTrim(aLinha[4]), AllTrim(aLinha[5]), AllTrim(aLinha[6]), AllTrim(aLinha[7]) })
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
			xProdut := PadR(aArqCsv[lin][1],TamSx3("B7_COD")[1])
			xArmaze := PadR(aArqCsv[lin][2],TamSx3("B7_LOCAL")[1])
			xDocInv := PadR(aArqCsv[lin][3],TamSx3("B7_DOC")[1])
			xQtdInv := StrTran(aArqCsv[lin][4],".","")
			xQtdInv := StrTran(xQtdInv,",",".")
			xQtdInv := Val(xQtdInv)
			xDatInv := CtoD(aArqCsv[lin][5])
			xEndere := PadR(aArqCsv[lin][6],TamSx3("B7_LOCALIZ")[1])
			xContag := PadR(aArqCsv[lin][7],TamSx3("B7_CONTAGE")[1])

			AAdd(aLinha,xSeqLin)
			AAdd(aLinha,xProdut)
			AAdd(aLinha,xArmaze)
			AAdd(aLinha,xDocInv)
			AAdd(aLinha,xQtdInv)
			AAdd(aLinha,xDatInv)
			AAdd(aLinha,xEndere)
			AAdd(aLinha,xContag)

			DbSelectArea("NNR")
			DbSetOrder(1)
			If !DbSeek( xFilial("NNR") + xArmaze )
				GravaLog(aLinha,"ARMAZEM NAO LOCALIZADO",.T.)
				Loop
			Endif

			DbSelectArea("SB1")
			DbSetOrder(1)
			If !DbSeek( xFilial("SB1") + xProdut )
				GravaLog(aLinha,"PRODUTO NAO LOCALIZADO",.T.)
				Loop
			Else
				If SB1->B1_RASTRO == "L"
					GravaLog(aLinha,"PRODUTO UTILIZA RASTREABILIDADE",.T.)
					Loop
				ElseIf SB1->B1_LOCALIZ == "S"
					If Empty(xEndere)
						GravaLog(aLinha,"PRODUTO UTILIZA ENDERECAMENTO",.T.)
						Loop
					Else
						DbSelectArea("SBE")
						DbSetOrder(1)
						If !DbSeek( xFilial("SBE") + xArmaze + xEndere )
							GravaLog(aLinha,"ENDERECO NAO LOCALIZADO",.T.)
							Loop
						Endif
					Endif
				Else
					If !Empty(xEndere)
						GravaLog(aLinha,"PRODUTO NAO UTILIZA ENDERECAMENTO",.T.)
						Loop
					Endif
				Endif
			Endif

			If SB1->B1_MSBLQL == "1"
				GravaLog(aLinha,"PRODUTO BLOQUEADO",.T.)
				Loop
			Endif

			If Empty(DtoS(xDatInv))
				GravaLog(aLinha,"DATA INVALIDA",.T.)
				Loop
			Else
				If xDatInv <= GetMv("MV_ULMES")
					GravaLog(aLinha,"DATA ANTERIOR AO ULTIMO FECHAMENTO",.T.)
				Endif
			Endif

			DbSelectArea("SB2")
			DbSetOrder(1)
			If !DbSeek( xFilial("SB2") + xProdut + xArmaze )
				RecLock("SB2",.T.)
				SB2->B2_FILIAL  := xFilial("SB2")
				SB2->B2_COD     := xProdut
				SB2->B2_LOCAL   := xArmaze
				SB2->B2_LOCALIZ := AllTrim(NNR->NNR_DESCRI)
				SB2->B2_TIPO    := "1"
				MsUnLock()
			Endif

			DbSelectArea("SB7")
			DbSetOrder(1)
			If DbSeek( xFilial("SB7") + DtoS(xDatInv) + xProdut + xArmaze + xEndere + Space(TamSx3("B7_NUMSERI")[1]) + Space(TamSx3("B7_LOTECTL")[1]) + Space(TamSx3("B7_NUMLOTE")[1]) + xContag )
				GravaLog(aLinha,"INVENTARIO JA CADASTRADO",.T.)
				Loop
			Endif

			AAdd(aLinhOk,{ xSeqLin, xProdut, xArmaze, xDocInv, xQtdInv, xDatInv, xEndere, xContag })

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
@since: 29/09/2025
@version: P12
@database: MSSQL
/*/
Static Function GravaLog(aLinha,cMsgErro,lErro)

AAdd(aArqLog,{ AllTrim(aLinha[1]),; // LOG->LOG_SEQ
			   AllTrim(aLinha[2]),; // LOG->LOG_PRD
			   AllTrim(aLinha[3]),; // LOG->LOG_ARM
			   AllTrim(aLinha[4]),; // LOG->LOG_DOC
			   aLinha[5],; // LOG->LOG_QTD
			   aLinha[6],; // LOG->LOG_DAT
			   AllTrim(aLinha[7]),; // LOG->LOG_END
			   AllTrim(aLinha[8]),; // LOG->LOG_CON
			   IIf(lErro,"Sim","Não"),; // LOG->LOG_ERR
			   AllTrim(cMsgErro) }) // LOG->LOG_MSG

Return

/*/
{Protheus.doc}
@function: ProcInvArq
@descrip: Executa o processamento
@
@type: function
@author: Fábrica ERP.BR
@since: 29/09/2025
@version: P12
@database: MSSQL
/*/
Static Function ProcInvArq(nRadio1,aLinhOk)

Local aVetor := {}
Local inv, log

Private lMsErroAuto    := .F.
Private lMsHelpAuto    := .T.
Private lAutoErrNoFile := .T.

For inv := 1 to Len(aLinhOk)

	xSeqLin := aLinhOk[inv][1]
	xProdut := aLinhOk[inv][2]
	xArmaze := aLinhOk[inv][3]
	xDocInv := aLinhOk[inv][4]
	xQtdInv := aLinhOk[inv][5]
	xDatInv := aLinhOk[inv][6]
	xEndere := aLinhOk[inv][7]
	xContag := aLinhOk[inv][8]

	If nRadio1 == 1 // Simulação

		AAdd(aArqLog,{ xSeqLin,; // LOG->LOG_SEQ
					   AllTrim(xProdut),; // LOG->LOG_PRD
					   AllTrim(xArmaze),; // LOG->LOG_ARM
					   AllTrim(xDocInv),; // LOG->LOG_DOC
					   xQtdInv,; // LOG->LOG_QTD
					   xDatInv,; // LOG->LOG_DAT
					   AllTrim(xEndere),; // LOG->LOG_END
					   AllTrim(xContag),; // LOG->LOG_CON
					   "Não",; // LOG->LOG_ERR
					   "SIMULAÇÃO VALIDADA" }) // LOG->LOG_MSG

	ElseIf nRadio1 == 2 // Execução

		aVetor := {}
		AAdd(aVetor,{ "B7_COD"     , xProdut , Nil })
		AAdd(aVetor,{ "B7_LOCAL"   , xArmaze , Nil })
		AAdd(aVetor,{ "B7_DOC"     , xDocInv , Nil })
		AAdd(aVetor,{ "B7_QUANT"   , xQtdInv , Nil })
		AAdd(aVetor,{ "B7_DATA"    , xDatInv , Nil })
		AAdd(aVetor,{ "B7_ESCOLHA" , " "     , Nil })
		AAdd(aVetor,{ "B7_CONTAGE" , xContag , Nil })
		If !Empty(xEndere)
			AAdd(aVetor,{ "B7_LOCALIZ" , xEndere , Nil })
		Endif

		lMsErroAuto    := .F.
		lMsHelpAuto    := .T.
		lAutoErrNoFile := .T.
		MsExecAuto( {|x,y,z| MATA270(x,y,z)}, aVetor, .T., 3)

		If !lMsErroAuto

			AAdd(aArqLog,{ xSeqLin,; // LOG->LOG_SEQ
						AllTrim(xProdut),; // LOG->LOG_PRD
						AllTrim(xArmaze),; // LOG->LOG_ARM
						AllTrim(xDocInv),; // LOG->LOG_DOC
						xQtdInv,; // LOG->LOG_QTD
						xDatInv,; // LOG->LOG_DAT
						AllTrim(xEndere),; // LOG->LOG_END
						AllTrim(xContag),; // LOG->LOG_CON
						"Não",; // LOG->LOG_ERR
						"CADASTRADO COM SUCESSO" }) // LOG->LOG_MSG

		Else

			aLog := GetAutoGrLog()
			bMsg := ""
			For log := 1 to Len(aLog)
				bMsg += AllTrim(Substr(aLog[log],9))
			Next log

			AAdd(aArqLog,{ xSeqLin,; // LOG->LOG_SEQ
						AllTrim(xProdut),; // LOG->LOG_PRD
						AllTrim(xArmaze),; // LOG->LOG_ARM
						AllTrim(xDocInv),; // LOG->LOG_DOC
						xQtdInv,; // LOG->LOG_QTD
						xDatInv,; // LOG->LOG_DAT
						AllTrim(xEndere),; // LOG->LOG_END
						AllTrim(xContag),; // LOG->LOG_CON
						"Sim",; // LOG->LOG_ERR
						bMsg }) // LOG->LOG_MSG

		Endif

	Endif

Next doc

// Cria arquivo temporário
pCriaTemp()

// Carrega arquivo temporário
pLoadTemp()

// Log de Ocorrências
u_InventLog()

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
@since: 29/09/2025
@version: P12
@database: MSSQL
/*/
Static Function pCriaTemp()

Local _aTmp1 := {}

oTemp1 := FWTemporaryTable():New("LOG")

AAdd ( _aTmp1, {"LOG_SEQ", "C", 005, 00} )
AAdd ( _aTmp1, {"LOG_PRD", "C", TamSx3("B7_COD")[1], 00} )
AAdd ( _aTmp1, {"LOG_ARM", "C", TamSx3("B7_LOCAL")[1], 00} )
AAdd ( _aTmp1, {"LOG_DOC", "C", TamSx3("B7_DOC")[1], 00} )
AAdd ( _aTmp1, {"LOG_QTD", "N", TamSx3("B7_QUANT")[1], TamSx3("B7_QUANT")[2]} )
AAdd ( _aTmp1, {"LOG_DAT", "D", 008, 00} )
AAdd ( _aTmp1, {"LOG_END", "C", TamSx3("B7_LOCALIZ")[1], 00} )
AAdd ( _aTmp1, {"LOG_CON", "C", TamSx3("B7_CONTAGE")[1], 00} )
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
@since: 29/09/2025
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
	LOG->LOG_PRD := aArqLog[log][2]
	LOG->LOG_ARM := aArqLog[log][3]
	LOG->LOG_DOC := aArqLog[log][4]
	LOG->LOG_QTD := aArqLog[log][5]
	LOG->LOG_DAT := aArqLog[log][6]
	LOG->LOG_END := aArqLog[log][7]
	LOG->LOG_CON := aArqLog[log][8]
	LOG->LOG_ERR := aArqLog[log][9]
	LOG->LOG_MSG := aArqLog[log][10]
	MsUnLock()
Next log

Return

/*/
{Protheus.doc}
@function: InventLog
@descrip: Imprime o Log
@
@type: function
@author: Fábrica ERP.BR
@since: 29/09/2025
@version: P12
@database: MSSQL
/*/
User Function InventLog()

Local oRepLog

oRepLog := InventLog()

If oRepLog == Nil
	Return
Endif

oRepLog:PrintDialog()

Return

/*/
{Protheus.doc}
@function: InventLog
@descrip: Executa impressao
@
@type: function
@author: Fábrica ERP.BR
@since: 29/09/2025
@version: P12
@database: MSSQL
/*/
Static Function InventLog()

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
TRCell():New(oSection1, "PRD", "LOG", "Produto"    , "@!" , 020, , { || LOG->LOG_PRD } )
TRCell():New(oSection1, "DES", "LOG", "Descrição"  , "@!" , 100, , { || Posicione("SB1",1,xFilial("SB1")+LOG->LOG_PRD,"B1_DESC") } )
TRCell():New(oSection1, "ARM", "LOG", "Armazém"    , "@!" , 010, , { || LOG->LOG_ARM } )
TRCell():New(oSection1, "DOC", "LOG", "Documento"  , "@!" , 020, , { || LOG->LOG_DOC } )
TRCell():New(oSection1, "QTD", "LOG", "Quantidade" , "@E 9,999,999.99" , 015, , { || LOG->LOG_QTD } )
TRCell():New(oSection1, "DAT", "LOG", "Data Digit" , ""   , 010, , { || LOG->LOG_DAT } )
TRCell():New(oSection1, "END", "LOG", "Endereço"   , "@!" , 020, , { || LOG->LOG_END } )
TRCell():New(oSection1, "END", "LOG", "Contagem"   , "@!" , 005, , { || LOG->LOG_CON } )
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
@since: 29/09/2025
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

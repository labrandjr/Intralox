#include "protheus.ch"
#include "topconn.ch"
#include "rwmake.ch"
#include "tbiconn.ch"
#include "tbicode.ch"

/*/
{Protheus.doc}
@function: U6CSVSA5
@descrip: Importa produto x fornecedor a partir de arquivo CSV com leiaute definido
@
@type: function
@author: Fábrica ERP.BR
@since: 05/01/2026
@version: P12
@database: MSSQL
/*/
User Function U6CSVSA5()

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

oDlg410 := MsDialog():New(nDlg1,nDlg2,nDlg3,nDlg4,"Importa Produto x Fornecedor",,,,,,,,,.T.)

@ 042,005 RADIO oRadio1 VAR nRadio1 3D SIZE 070,010 PROMPT "Simulação","Execução" OF oDlg410 PIXEL

@ 070,020 SAY "Arquivo:" OF oDlg410 PIXEL SIZE 055,009
oGetRat:= TGet():New(068,050,{|u| if(PCount()>0,cArqCsv:=u,cArqCsv)},oDlg410,240,010,"@X",{|o|},,,,,,.T.,,, {|| .T. } ,,,,,,,"cArqCsv")
oTButton := TButton():New(068,300,"...",oDlg410,{||AbreArq(@cArqCsv,oGetRat)},020,010,,,.F.,.T.,.F.,,.F.,,,.F.)

oDlg410:Activate(,,,.T.,{|| ValidLib(cArqCsv,@aLinhOk,nRadio1) },,{|| EnchoiceBar(oDlg410,bOk410,bCan410) } )

If nOpc410 == 1
	If nRadio1 == 1
		FwMsgRun(, { || ProcImpSa5(nRadio1,aLinhOk) },,"Aguarde, simulando a importação")
	Else
		FwMsgRun(, { || ProcImpSa5(nRadio1,aLinhOk) },,"Aguarde, executando a importação")
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
@since: 05/01/2026
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
@since: 05/01/2026
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
					If Len(aLinha) <> 4
						MsgAlert("Tamanho da linha invalido: "+AllTrim(STR(Len(aLinha)))+" posicoes."+cEOL+"O leiaute deve ter 4 posicoes.")
						lTamLin := .F.
						Exit
					Endif
					//
					AAdd(aArqCsv,{ AllTrim(aLinha[1]),;  // A5_FORNECE
								   AllTrim(aLinha[2]),;  // A5_LOJA
								   AllTrim(aLinha[3]),;  // A5_PRODUTO
								   AllTrim(aLinha[4]) }) // A5_CODPRF
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
			xCodFor := PadR(aArqCsv[lin][1],TamSx3("A5_FORNECE")[1])
			xLojFor := PadR(aArqCsv[lin][2],TamSx3("A5_LOJA")[1])
			xProdut := PadR(aArqCsv[lin][3],TamSx3("A5_PRODUTO")[1])
			xPrdFor := PadR(aArqCsv[lin][4],TamSx3("A5_CODPRF")[1])

			AAdd(aLinha,xSeqLin)
			AAdd(aLinha,xCodFor)
			AAdd(aLinha,xLojFor)
			AAdd(aLinha,xProdut)
			AAdd(aLinha,xPrdFor)

			DbSelectArea("SA2")
			DbSetOrder(1)
			If !DbSeek( xFilial("SA2") + xCodFor + xLojFor )
				GravaLog(aLinha,"FORNECEDOR NAO LOCALIZADO",.T.)
				Loop
			Endif

			DbSelectArea("SB1")
			DbSetOrder(1)
			If !DbSeek( xFilial("SB1") + xProdut )
				GravaLog(aLinha,"PRODUTO NAO LOCALIZADO",.T.)
				Loop
			Endif

			AAdd(aLinhOk,{ xSeqLin, xCodFor, xLojFor, xProdut, xPrdFor })

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
@since: 05/01/2026
@version: P12
@database: MSSQL
/*/
Static Function GravaLog(aLinha,cMsgErro,lErro)

AAdd(aArqLog,{ AllTrim(aLinha[1]),; // LOG->LOG_SEQ
			   AllTrim(aLinha[2]),; // LOG->LOG_FOR
			   AllTrim(aLinha[3]),; // LOG->LOG_LOJ
			   AllTrim(aLinha[4]),; // LOG->LOG_PRD
			   AllTrim(aLinha[5]),; // LOG->LOG_PRF
			   IIf(lErro,"Sim","Não"),; // LOG->LOG_ERR
			   AllTrim(cMsgErro) }) // LOG->LOG_MSG

Return

/*/
{Protheus.doc}
@function: ProcImpSa5
@descrip: Executa o processamento
@
@type: function
@author: Fábrica ERP.BR
@since: 05/01/2026
@version: P12
@database: MSSQL
/*/
Static Function ProcImpSa5(nRadio1,aLinhOk)

Local csv

For csv := 1 to Len(aLinhOk)

	xSeqLin := aLinhOk[csv][1]
	xFornec := aLinhOk[csv][2]
	xLojFor := aLinhOk[csv][3]
	xProdut := aLinhOk[csv][4]
	xPrdFor := aLinhOk[csv][5]

	If nRadio1 == 1 // Simulação

		AAdd(aArqLog,{ xSeqLin,; // LOG->LOG_SEQ
					   AllTrim(xFornec),; // LOG->LOG_FOR
					   AllTrim(xLojFor),; // LOG->LOG_LOJ
					   AllTrim(xProdut),; // LOG->LOG_PRD
					   AllTrim(xPrdFor),; // LOG->LOG_PRF
					   "Não",; // LOG->LOG_ERR
					   "SIMULAÇÃO VALIDADA" }) // LOG->LOG_MSG

	ElseIf nRadio1 == 2 // Execução

		DbSelectArea("SA2")
		DbSetOrder(1)
		DbSeek( xFilial("SA2") + xFornec + xLojFor )

		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek( xFilial("SB1") + xProdut )

		DbSelectArea("SA5")
		DbSetOrder(1)
		If !DbSeek( xFilial("SA5") + SA2->A2_COD + SA2->A2_LOJA + SB1->B1_COD )
			RecLock("SA5",.T.)
			SA5->A5_FILIAL	:= xFilial("SA5")
			SA5->A5_FORNECE	:= SA2->A2_COD
			SA5->A5_LOJA	:= SA2->A2_LOJA
			SA5->A5_NOMEFOR	:= SA2->A2_NOME
			SA5->A5_PRODUTO	:= SB1->B1_COD
			SA5->A5_NOMPROD	:= SB1->B1_DESC
			SA5->A5_CODPRF  := xPrdFor
			SA5->A5_CHAVE   := A060Chave()
			MsUnLock()
			cTxtLog := "CADASTRADO COM SUCESSO"
		Else
			RecLock("SA5",.F.)
			SA5->A5_CODPRF := xPrdFor
			MsUnLock()
			cTxtLog := "ALTERADO COM SUCESSO"
		Endif

		AAdd(aArqLog,{ xSeqLin,; // LOG->LOG_SEQ
					   AllTrim(xFornec),; // LOG->LOG_FOR
					   AllTrim(xLojFor),; // LOG->LOG_LOJ
					   AllTrim(xProdut),; // LOG->LOG_PRD
					   AllTrim(xPrdFor),; // LOG->LOG_PRF
					   "Não",; // LOG->LOG_ERR
					   cTxtLog }) // LOG->LOG_MSG

	Endif

Next doc

// Cria arquivo temporário
pCriaTemp()

// Carrega arquivo temporário
pLoadTemp()

// Log de Ocorrências
u_LogOcorre()

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
@since: 05/01/2026
@version: P12
@database: MSSQL
/*/
Static Function pCriaTemp()

Local _aTmp1 := {}

oTemp1 := FWTemporaryTable():New("LOG")

AAdd ( _aTmp1, {"LOG_SEQ", "C", 005, 00} )
AAdd ( _aTmp1, {"LOG_FOR", "C", TamSx3("A5_FORNECE")[1], 00} )
AAdd ( _aTmp1, {"LOG_LOJ", "C", TamSx3("A5_LOJA")[1], 00} )
AAdd ( _aTmp1, {"LOG_PRD", "C", TamSx3("A5_PRODUTO")[1], 00} )
AAdd ( _aTmp1, {"LOG_PRF", "C", TamSx3("A5_CODPRF")[1], 00} )
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
@since: 05/01/2026
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
	LOG->LOG_FOR := aArqLog[log][2]
	LOG->LOG_LOJ := aArqLog[log][3]
	LOG->LOG_PRD := aArqLog[log][4]
	LOG->LOG_PRF := aArqLog[log][5]
	LOG->LOG_ERR := aArqLog[log][6]
	LOG->LOG_MSG := aArqLog[log][7]
	MsUnLock()
Next log

Return

/*/
{Protheus.doc}
@function: LogOcorre
@descrip: Imprime o Log
@
@type: function
@author: Fábrica ERP.BR
@since: 05/01/2026
@version: P12
@database: MSSQL
/*/
User Function LogOcorre()

Local oRepLog

oRepLog := LogOcorre()

If oRepLog == Nil
	Return
Endif

oRepLog:PrintDialog()

Return

/*/
{Protheus.doc}
@function: LogOcorre
@descrip: Executa impressao
@
@type: function
@author: Fábrica ERP.BR
@since: 05/01/2026
@version: P12
@database: MSSQL
/*/
Static Function LogOcorre()

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
TRCell():New(oSection1, "FOR", "LOG", "Fornecedor" , "@!" , 020, , { || LOG->LOG_FOR } )
TRCell():New(oSection1, "LOJ", "LOG", "Loja"       , "@!" , 005, , { || LOG->LOG_LOJ } )
TRCell():New(oSection1, "NOM", "LOG", "Nome"       , "@!" , 100, , { || Posicione("SA2",1,xFilial("SA2")+LOG->LOG_FOR + LOG->LOG_LOJ,"A2_NOME") } )
TRCell():New(oSection1, "PRD", "LOG", "Produto"    , "@!" , 020, , { || LOG->LOG_PRD } )
TRCell():New(oSection1, "DES", "LOG", "Descrição"  , "@!" , 100, , { || Posicione("SB1",1,xFilial("SB1")+LOG->LOG_PRD,"B1_DESC") } )
TRCell():New(oSection1, "ARM", "LOG", "Prod.Forn." , "@!" , 020, , { || LOG->LOG_PRF } )
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

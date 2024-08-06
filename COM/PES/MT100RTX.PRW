#include "protheus.ch"
#include "topconn.ch"
#include "rwmake.CH"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MT100RTX  ¦ Autor ¦ Luis Brandini    ¦ Data  ¦ Nov-2023    ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Importação do rateio contábil no item do Doc.Entrada.      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo INTRALOX 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MT100RTX()

Local aHdrRat := ParamIxb[1]
Local aColRat := ParamIxb[2]
Local lRatCsv := SuperGetMv("MV_ZRATCSV",.F.,.T.)
Local nRetOpc := 0

If FWCodEmp() $("99,U6")
    If lRatCsv
        nRetOpc := u_AskTipRat()
        If nRetOpc == 1 // 1=Importar Csv | 2=Digitar
            MsgRun("Aguarde, importando rateios","Processando",{|| aColRat := u_ImpRatCsv(@aHdrRat,@aColRat) })
        Endif
    Endif
Endif

Return(aColRat)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ImpRatCsv ¦ Autor ¦ Luis Brandini    ¦ Data  ¦ Nov-2023    ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Executa leitura do arquivo p/ preenchimento do rataio.     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo INTRALOX 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function ImpRatCsv(aHdrRat,aColRat)

Local _x
Private cArquivo := Space(30)
Private lOkFile  := .F.
Private cEOL     := CHR(13)+CHR(10)
Private nBytes   := 0
Private nHandle  := 0
Private lProcOk  := .T.
Private nTotRat  := 0
Private aRatCsv  := {}
Private cMsgErr  := "Inconsistências:"+cEOL+cEOL

cArquivo := cGetFile("Arquivos CSV|*.CSV|",OemToAnsi("Selecione o arquivo"))
cArquivo := AllTrim(cArquivo)
If !Empty(cArquivo)
	If File(cArquivo)
		If MsgYesNo("Arquivo a ser processado: "+cEOL+cArquivo+"."+cEOL+"Deseja prosseguir ?","Aviso","INFO")
			lOkFile := .T.
		Endif
	Else
		MsgAlert("Arquivo não encontrado.")
	Endif
Else
	MsgAlert("Arquivo não selecionado.")
Endif

If lOkFile

	nHandle := fOpen(cArquivo,2)

	If nHandle == -1
		Alert("Problema na abertura do arquivo "+cArquivo+".")
		Return(aColRat)
	Endif

    nTamArq := fFileSize(nHandle)
    While ( !Empty((cString := fReadFile(nHandle,nTamArq,0,@nBytes))) )
        
        // Fim de Arquivo
        If Len(cString) < 2
            Exit
        Endif

        nPosic  := 0
        aLinha  := {}
        cTxtLin := cString
        While (!Empty(cTxtLin))
            If (((nPosic := AT(";",cTxtLin)) > 0))
                AAdd(aLinha,Substr(cTxtLin,1,nPosic-1))
                cTxtLin := Stuff(cTxtLin,1,nPosic,"")
            Else
                AAdd(aLinha,Substr(cTxtLin,1,Len(AllTrim(cTxtLin))))
                cTxtLin := Stuff(cTxtLin,1,Len(cTxtLin),"")
            Endif	
        Enddo

        // Estrutura de aLinha:
        // [01] - % Rateio
        // [02] - C.Custo
        // [03] - Conta

        If Len(aLinha) <> 3
            MsgInfo("Atenção..., Estrutura do arquivo CSV inválida ("+AllTrim(STR(Len(aLinha)))+" posições)."+cEOL+"O layout deve conter 3 posições.")
            lProcOk  := .F.
            Exit
        Endif
        
        If Len(aLinha) > 0

            zPerRat := StrTran(AllTrim(aLinha[1]),".","")
            zPerRat := StrTran(zPerRat,",",".")
            zPerRat := Val(zPerRat)
            zCCusto := PadR(aLinha[2],TamSx3("CTT_CUSTO")[1])
            zConta  := PadR(aLinha[3],TamSx3("CT1_CONTA")[1])
            lTudoOk := .T.
            
            DbSelectArea("CTT")
            DbSetOrder(1)
            If !DbSeek( xFilial("CTT") + zCCusto )
                cMsgErr += "C.Custo não localizado: "+AllTrim(zCCusto) + cEOL
                lProcOk := .F.
            Else
                If CTT->CTT_BLOQ == "1"
                    cMsgErr += "C.Custo bloqueado para uso: "+AllTrim(zCCusto) + cEOL
                    lProcOk := .F.
                Endif
            Endif

            DbSelectArea("CT1")
            DbSetOrder(1)
            If !DbSeek( xFilial("CT1") + zConta )
                cMsgErr += "Conta contábil não localizada: "+AllTrim(zConta) + cEOL
                lProcOk := .F.
            Else
                If CT1->CT1_BLOQ == "1"
                    cMsgErr += "Conta contábil bloqueada para uso: "+AllTrim(zConta) + cEOL
                    lProcOk := .F.
                Endif
            Endif

            If lProcOk
                AAdd(aRatCsv,{zPerRat, zCCusto, zConta})
                nTotRat += zPerRat
            Endif

        Endif
            
    Enddo

	fClose(nHandle)

    If lProcOk
        If nTotRat <> 100
            MsgInfo("O total do rateio deve ser 100%."+cEOL+"A soma do arquivo é igual a "+AllTrim(STR(nTotRat,7,2))+" %")
            lProcOk := .F.
        Endif
    Else
        MsgInfo(cMsgErr)
    Endif

    zSeq := 0
    zSeq := StrZero(zSeq,TamSx3("DE_ITEM")[1])
    If lProcOk .And. Len(aRatCsv) > 0
        aColRat := {}
        For _x := 1 to Len(aRatCsv)
            zSeq := Soma1(zSeq)
            zPer := aRatCsv[_x][1]
            zCCu := aRatCsv[_x][2]
            zCta := aRatCsv[_x][3]
            zIte := Space(TamSx3("CTD_ITEM")[1])
            zCla := Space(TamSx3("CTH_CLVL")[1])
            AAdd(aColRat,{zSeq,zPer,zCCu,zCta,zIte,zCla,"SDE",0,.F.})
        Next _x
    Endif

Endif

Return(aColRat)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fReadFile ¦ Autor ¦ Fabrica ERPBR ¦ 	  Data ¦  Nov-2023	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Efetua leitura do arquivo e retorna conteudo da linhaa.	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo INTRALOX										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function fReadFile(nHandle,xFileSize,xBytesRead,nBytes)

Local nBytesRead := IIf(!((xBytesRead == 0) .Or. (xBytesRead == Nil)),xBytesRead,IIf(xFileSize < 1536,xFileSize,1536)) // Indica o numero de bytes a serem lidos
Local cBuffer    := Space(nBytesread) // Guarda o conteudo lido
Local nPosition  := 0 // Posicao do caracter 13 (return)
Local nIncbytes  := Nil // Incremento de bytes 2 CHR(13) + CHR(10)
Local xReturn    := Nil // Retorno da funcao

If ( ((FREAD(nHandle,@cBuffer,nBytesRead) = nBytesRead) .Or. (!Empty(cBuffer))) )
	// Verifica se procura o caracter 13 para identificar o registro
	xReturn := Substr(cBuffer,1,IIf(((nPosition := AT(CHR(13),cBuffer)) > 0),(nPosition - 1),Len(cBuffer)))
	// Verifica se incrementa bytes
	nIncBytes := IIf(nPosition > 0,2,0)
	// Bytes ja lidos somando os caracteres especiais
	nBytes := (nBytes + (Len(xReturn) + nIncBytes))
	// Retorna o descritor se necessario
	FSEEK(nHandle,(-1 * ABS((Len(cBuffer) - (Len(xReturn) + nIncBytes)))),1)
Endif

Return(xReturn)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fFileSize ¦ Autor ¦ Fabrica ERPBR ¦ 	  Data ¦  Nov-2023	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Obtem o tamanho do arquivo texto.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo INTRALOX										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function fFileSize(xHandle)

Local nLength := FSEEK(xHandle,0,2)
FSEEK(nHandle,0)

Return(nLength)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ AskTipRat ¦ Autor ¦ Fabrica ERPBR ¦ 	  Data ¦ Nov-2023	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Rateio digitado ou importado csv - solicita confirmação.   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo INTRALOX										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function AskTipRat()

Local nOpcRat := 0
Local bOkRat  := {|| nOpcRat:=1,oDlgRat:End() }
Local bCanRat := {|| nOpcRat:=0,oDlgRat:End() }
Local nRadio1 := 1
Local nRetOpc := 0
Local oDlgRat,oRadio1

nDlg1 := 001
nDlg2 := 001
nDlg3 := 150
nDlg4 := 376

DEFINE MSDIALOG oDlgRat FROM nDlg1,nDlg2 TO nDlg3,nDlg4 TITLE "Rateio" OF oDlgRat PIXEL
@ 042,065 RADIO oRadio1 VAR nRadio1 3D SIZE 70,11 PROMPT "Importar Csv","Digitar" OF oDlgRat PIXEL
ACTIVATE MSDIALOG oDlgRat ON INIT EnchoiceBar(oDlgRat,bOkRat,bCanRat) CENTERED

If nOpcRat == 1
	nRetOpc := nRadio1
Endif

Return(nRetOpc)

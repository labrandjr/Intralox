#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} U6PCP002
Processo implementado para tratamento de dados no arquivo CSV gerado pelo sistema local.
O resultado do processamento será a geração de novo arquivo CSV com os dados preparados para importação do
cadastro de produtos ou cadastro de estrutura.

@type function
@author	Fábrica ERP.BR
@since 10/05/2024
@version P12
@database MSSQL
/*/

User Function U6PCP002()

Local nOpcDwn := 0
Local bOkDwn  := {|| nOpcDwn:=1,oDlgDwn:End() }
Local bCanDwn := {|| nOpcDwn:=0,oDlgDwn:End() }
Local nRadio1 := 1
Local oDlgDwn,oRadio1

nDlg1 := 001
nDlg2 := 001
nDlg3 := 170
nDlg4 := 576

DEFINE MSDIALOG oDlgDwn FROM nDlg1,nDlg2 TO nDlg3,nDlg4 TITLE "Gerador de Planilha CSV" OF oDlgDwn PIXEL
@ 042,105 RADIO oRadio1 VAR nRadio1 3D SIZE 70,11 PROMPT "Produtos","Estrutura","Ambos" OF oDlgDwn PIXEL
ACTIVATE MSDIALOG oDlgDwn ON INIT EnchoiceBar(oDlgDwn,bOkDwn,bCanDwn) CENTERED

If nOpcDwn == 1
	U_U6PCPEXE(nRadio1)
Endif

Return

User Function U6PCPEXE(nRadio1)

Private cArquivo := Space(30)
Private lOkFile  := .F.
Private nBytes   := 0
Private nHandle  := 0
Private oProcess

cArquivo := cGetFile("Arquivos CSV|*.CSV|",OemToAnsi("Selecione o arquivo"))
cArquivo := AllTrim(cArquivo)
If !Empty(cArquivo)
	If File(cArquivo)
		If MsgYesNo("Arquivo a ser processado: "+cArquivo+". Deseja prosseguir ?","Aviso","INFO")
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
		Return
	Endif

	If nRadio1 == 1
		If MsgYesNo("Confirma o processamento - Gerador CSV Produtos ?","Aviso","INFO")
			oProcess := MsNewProcess():New( { | lEnd | lOk := U6ProdCsv() }, "Processando", "Aguarde, processando ...", .F. )
			oProcess:Activate()
		Endif
	ElseIf nRadio1 == 2
		If MsgYesNo("Confirma o processamento - Gerador CSV Estrutura ?","Aviso","INFO")
			oProcess := MsNewProcess():New( { | lEnd | lOk := U6EstrCsv() }, "Processando", "Aguarde, processando ...", .F. )
			oProcess:Activate()
		Endif
	Else
		If MsgYesNo("Confirma o processamento - Gerador CSV Produtos e Estrutura ?","Aviso","INFO")
			oProcess := MsNewProcess():New( { | lEnd | lOk := U6ProdCsv() }, "Processando", "Aguarde, processando ...", .F. )
			oProcess:Activate()
			oProcess := MsNewProcess():New( { | lEnd | lOk := U6EstrCsv() }, "Processando", "Aguarde, processando ...", .F. )
			oProcess:Activate()
		Endif
	Endif

	fClose(nHandle)

Endif

Return

// ************** //
// ** Produtos ** //
// ************** //
Static Function U6ProdCsv()

Local nCount := 0
Local nLinha := 0
Local lCabecArq := .T.
Local lTudOk    := .F.
Local cInsep    := ""
Private oTempTable

If Select("TMP") > 0
	TMP->(DbCloseArea())
Endif

pTrab01()

nTamArq := fFileSize(nHandle)
oProcess:SetRegua1(nTamArq/27)
While ( !Empty((cString := fReadFile(nHandle,nTamArq,0,@nBytes))) )
	
	oProcess:IncRegua1("Analisando arquivo csv..")

	If lCabecArq
		If AllTrim(cString) <> "Structure Level;Number;Version;Name;Quantity;Unit;State;Source;Assembly Mode;Context;Finish;Color;Material;Instance Material;Sheet Metal Style;Phantom Manufacturing Part"
			MsgAlert("Leiaute invalido. Verifique o cabeçalho: Structure Level;Number;Version;Name;Quantity;Unit;State;Source;Assembly Mode;Context;Finish;Color;Material;Instance Material;Sheet Metal Style;Phantom Manufacturing Part")
			Exit
		Else
			lCabecArq := .F.
			Loop
		Endif
	Endif

	// Fim de Arquivo
	If Len(cString) < 4
		Exit
	Endif

	nLinha  += 1
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
	// [01] - Structure Level
	// [02] - Number
	// [03] - Version
	// [04] - Name
	// [05] - Quantity
	// [06] - Unit
	// [07] - State
	// [08] - Source
	// [09] - Assembly Mode
	// [10] - Context
	// [11] - Finish
	// [12] - Color
	// [13] - Material
	// [14] - Instance Material
	// [15] - Sheet Metal Style
	// [16] - Phantom Manufacturing Part

	If Len(aLinha) <> 16
		MsgInfo("Atenção..., Estrutura do arquivo CSV inválida na Linha "+AllTrim(STR(nLinha))+" ("+AllTrim(STR(Len(aLinha)))+" posições). O layout deve conter 16 posições.")
		Return
	Endif
	
	If Len(aLinha) > 0

		lTudOk := .T.
		cNivel := AllTrim(aLinha[1])
		If cNivel == cInsep
			Loop
		Else
			cInsep := ""
		Endif
		cProdu := PadR(AllTrim(aLinha[2]),TamSx3("B1_COD")[1])
		cModel := AllTrim(aLinha[9])
		If !(Substr(cProdu,1,4) $("DPP-,BELT,DPE-"))
			Loop
		Endif
		DbSelectArea("SB1")
		DbSetOrder(1)
		If DbSeek( xFilial("SB1") + cProdu )
			RecLock("SB1",.F.)
			SB1->B1_LOCPAD := "01"
			SB1->B1_CONTA  := IIf(SB1->B1_TIPO=="PA" .Or. Substr(SB1->B1_COD,1,3)=="DPE","311101030","113170002")
			MsUnLock()
			If cModel == "Inseparable"
				cInsep := AllTrim(STR(Val(cNivel)+1))
			Endif
			Loop
		Endif
		cDescr := AllTrim(aLinha[4])
		cDescr := u_ConvDescr(cDescr)
		If AT("SOFTWARE",Upper(cDescr)) > 0
			Loop
		Endif
		nCount += 1
		cTipoP := IIf(AT("DPE210",Upper(cDescr)) > 0,"PA","PI")
		cQuant := AllTrim(aLinha[5])
		lMilim := ( AT("Millimeter",cQuant) > 0 )
		cUnMed := IIf(lMilim,"MT","UN")
		cGrup2 := ""
		If AT("MOTOR GEAR",Upper(cDescr)) > 0
			cGrup2 := "MOT"
		ElseIf AT("SHAFT",Upper(cDescr)) > 0
			cGrup2 := "MAC"
		ElseIf AT("RNR",Upper(cDescr)) > 0
			cGrup2 := "RNR"
		ElseIf AT("2MM",Upper(cDescr)) > 0 .Or. AT("2 MM",Upper(cDescr)) .Or.;
			   AT("3MM",Upper(cDescr)) > 0 .Or. AT("3 MM",Upper(cDescr)) .Or.;
			   AT("5MM",Upper(cDescr)) > 0 .Or. AT("5 MM",Upper(cDescr))
			cGrup2 := "SHM"
		ElseIf AT("PNEUMATIC",Upper(cDescr)) > 0 .Or. AT("FESTO",Upper(cDescr)) > 0
			cGrup2 := "PNE"
		Endif

		DbSelectArea("TMP")
		DbSetOrder(1)
		If !DbSeek( cProdu )
			RecLock("TMP",.T.)
			TMP->TM_PRODUT  := cProdu
			TMP->TM_DESCRI  := cDescr
			TMP->TM_TIPO    := cTipoP
			TMP->TM_UM      := cUnMed
			TMP->TM_LOCPAD  := "01"
			TMP->TM_GRUPO   := "DPE"
			TMP->TM_ORIGEM  := "0"
			TMP->TM_QE      := 0
			TMP->TM_EMIN    := 0
			TMP->TM_ESTSEG  := 0
			TMP->TM_PE      := 0
			TMP->TM_TIPE    := "D"
			TMP->TM_LE      := 0
			TMP->TM_LM      := 0
			TMP->TM_TOLER   := 0
			TMP->TM_MRP     := "S"
			TMP->TM_CONTA   := IIf(cTipoP=="PA" .Or. Substr(cProdu,1,3)=="DPE","311101030","113170002")
			TMP->TM_POSIPI  := IIf(cTipoP=="PA" .Or. Substr(cProdu,1,3)=="DPE","84283300","72101100")
			TMP->TM_P_TIP   := "1"
			TMP->TM_PRVALID := 0
			TMP->TM_EMAX    := 0
			TMP->TM_PRODSBP := IIf(cModel=="Separable","P","C")
			TMP->TM_DESCR02 := cDescr
			TMP->TM_ZZGRP2  := cGrup2
			TMP->TM_SEQUEN  := StrZero(nCount,4)
			MsUnLock()
		Endif
		If cModel == "Inseparable"
			cInsep := AllTrim(STR(Val(cNivel)+1))
		Endif
	Endif
		
Enddo

If lTudOk
	FwMsgRun(, { || CsvProdutos() },,"Aguarde, gerando arquivo csv produtos")
Else
	MsgAlert("O arquivo csv não foi gerado. Verifique o arquivo selecionado.")
Endif	

TMP->(DbCloseArea())
oTempTable:Delete() 

Return

Static Function CsvProdutos()

Private cPathSB1 := "c:\csvintralox\produtos-"+DtoS(dDatabase)+"-"+Substr(StrTran(Time(),":",""),1,4)+".csv"
Private cDest := "c:\csvintralox\"
Private ENTER := CHR(13)+CHR(10)
Private nHdlSB1

If !ExistDir(cDest)
	MakeDir(cDest)
Endif

nHdlSB1 := fCreate(cPathSB1)
If nHdlSB1 < 0
	MsgBox("Falha na criação do arquivo de log: "+AllTrim(cPathSG1)+". Contate o Administrador.")
	Return
Endif

// Cabeçalho do arquivo
cTexto := "B1_COD;B1_DESC;B1_TIPO;B1_UM;B1_LOCPAD;B1_GRUPO;B1_ORIGEM;B1_QE;B1_EMIN;B1_ESTSEG;B1_PE;B1_TIPE;B1_LE;B1_LM;B1_TOLER;B1_MRP;B1_CONTA;B1_POSIPI;B1_P_TIP;B1_PRVALID;B1_EMAX;B1_PRODSBP;B1_DESCR02;B1_ZZGRP2"+ENTER
fWrite(nHdlSB1,cTexto)

DbSelectArea("TMP")
DbSetOrder(2)
TMP->(DbGotop())
While !Eof()
	cTexto := AllTrim(TMP->TM_PRODUT)+";"+AllTrim(TMP->TM_DESCRI)+";"+AllTrim(TMP->TM_TIPO)+";"+AllTrim(TMP->TM_UM)+";"+;
			  AllTrim(TMP->TM_LOCPAD)+";"+AllTrim(TMP->TM_GRUPO)+";"+AllTrim(TMP->TM_ORIGEM)+";"+AllTrim(STR(TMP->TM_QE))+";"+;
			  AllTrim(STR(TMP->TM_EMIN))+";"+AllTrim(STR(TMP->TM_ESTSEG))+";"+AllTrim(STR(TMP->TM_PE))+";"+AllTrim(TMP->TM_TIPE)+";"+;
			  AllTrim(STR(TMP->TM_LE))+";"+AllTrim(STR(TMP->TM_LM))+";"+AllTrim(STR(TMP->TM_TOLER))+";"+AllTrim(TMP->TM_MRP)+";"+;
			  AllTrim(TMP->TM_CONTA)+";"+AllTrim(TMP->TM_POSIPI)+";"+AllTrim(TMP->TM_P_TIP)+";"+AllTrim(STR(TMP->TM_PRVALID))+";"+;
			  AllTrim(STR(TMP->TM_EMAX))+";"+AllTrim(TMP->TM_PRODSBP)+";"+AllTrim(TMP->TM_DESCR02)+";"+AllTrim(TMP->TM_ZZGRP2)+ENTER
	fWrite(nHdlSB1,cTexto)
	TMP->(DbSkip())
Enddo

fClose(nHdlSB1)
MsgAlert("Arquivo gerado com sucesso:"+cPathSB1)

Return

// *************** //
// ** Estrutura ** //
// *************** //
Static Function U6EstrCsv()

Local nCount := 0
Local nLinha := 0
Local lCabecArq := .T.
Local aLastNiv  := {}
Local lTudOk    := .F.
Local cInsep    := ""
Private oTempTable

If Select("TMP") > 0
	TMP->(DbCloseArea())
Endif

pTrab02()

nTamArq := fFileSize(nHandle)
oProcess:SetRegua1(nTamArq/27)
While ( !Empty((cString := fReadFile(nHandle,nTamArq,0,@nBytes))) )
	
	oProcess:IncRegua1("Analisando arquivo csv..")

	If lCabecArq
		If AllTrim(cString) <> "Structure Level;Number;Version;Name;Quantity;Unit;State;Source;Assembly Mode;Context;Finish;Color;Material;Instance Material;Sheet Metal Style;Phantom Manufacturing Part"
			MsgAlert("Leiaute invalido. Verifique o cabeçalho: Structure Level;Number;Version;Name;Quantity;Unit;State;Source;Assembly Mode;Context;Finish;Color;Material;Instance Material;Sheet Metal Style;Phantom Manufacturing Part")
			Exit
		Else
			lCabecArq := .F.
			Loop
		Endif
	Endif

	// Fim de Arquivo
	If Len(cString) < 4
		Exit
	Endif

	nLinha  += 1
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
	// [01] - Structure Level
	// [02] - Number
	// [03] - Version
	// [04] - Name
	// [05] - Quantity
	// [06] - Unit
	// [07] - State
	// [08] - Source
	// [09] - Assembly Mode
	// [10] - Context
	// [11] - Finish
	// [12] - Color
	// [13] - Material
	// [14] - Instance Material
	// [15] - Sheet Metal Style
	// [16] - Phantom Manufacturing Part

	If Len(aLinha) <> 16
		MsgInfo("Atenção..., Estrutura do arquivo CSV inválida na Linha "+AllTrim(STR(nLinha))+" ("+AllTrim(STR(Len(aLinha)))+" posições). O layout deve conter 16 posições.")
		Return
	Endif
	
	If Len(aLinha) > 0

		lTudOk := .T.
		cNivel := AllTrim(aLinha[1])
		If cNivel == cInsep
			Loop
		Else
			cInsep := ""
		Endif
		cDescr := AllTrim(aLinha[4])
		If AT("SOFTWARE",Upper(cDescr)) > 0
			Loop
		Endif
		nCount += 1
		cProdu := PadR(AllTrim(aLinha[2]),TamSx3("B1_COD")[1])
		cQuant := AllTrim(aLinha[5])
		lMilim := ( AT("Millimeter",cQuant) > 0 )
		cQuant := StrTran(cQuant,"each","")
		cQuant := StrTran(cQuant,"Millimeter","")
		nQuant := Val(cQuant)
		If cNivel == "0"
			nQuant := 1
		Endif
		If lMilim
			nQuant := (nQuant / 1000)
		Endif
		cModel := AllTrim(aLinha[9])
		If !(Substr(cProdu,1,4) $("DPP-,BELT")) .And. Len(AllTrim(cProdu)) == 12
			cProdu := u_VersaoSb1(AllTrim(cProdu))
		Endif

		nPos := aScan(aLastNiv, {|x| x[1] == cNivel})
		If nPos == 0
			AAdd(aLastNiv,{cNivel, cProdu})
		Else
			aLastNiv[nPos][2] := cProdu
		Endif

		cCodPai := Space(254)
		If Val(cNivel) > 1
			cCodPai := ""
			nNivFor := Val(cNivel)
			While .T.
				nNivFor  -= 1
				cSeekNiv := AllTrim(STR(nNivFor))
				nPos := aScan(aLastNiv, {|x| x[1] == cSeekNiv})
				If nPos > 0
					cCodPai += aLastNiv[nPos][2]
				Endif
				If nNivFor == 0
					cCodPai := PadR(cCodPai,254)
					Exit
				Endif
			Enddo
		Endif

		DbSelectArea("TMP")
		DbSetOrder(1)
		If !DbSeek( PadR(cNivel,2) + cProdu + cCodPai )
			RecLock("TMP",.T.)
			TMP->TM_NIVEL  := cNivel
			TMP->TM_PRODUT := cProdu
			TMP->TM_CODPAI := cCodPai
			TMP->TM_SEQUEN := StrZero(nCount,4)
		Else
			RecLock("TMP",.F.)
		Endif
		TMP->TM_QUANT += nQuant
		MsUnLock()

		If cModel == "Inseparable"
			cInsep := AllTrim(STR(Val(cNivel)+1))
		Endif

	Endif
		
Enddo

If lTudOk
	FwMsgRun(, { || CsvEstrutura() },,"Aguarde, gerando arquivo csv estrutura")
Else
	MsgAlert("O arquivo csv não foi gerado. Verifique o arquivo selecionado.")
Endif	

TMP->(DbCloseArea())
oTempTable:Delete() 

Return

Static Function CsvEstrutura()

Private cPathSG1 := "c:\csvintralox\estrutura-"+DtoS(dDatabase)+"-"+Substr(StrTran(Time(),":",""),1,4)+".csv"
Private cDest := "c:\csvintralox\"
Private ENTER := CHR(13)+CHR(10)
Private nHdlSG1

If !ExistDir(cDest)
	MakeDir(cDest)
Endif

nHdlSG1 := fCreate(cPathSG1)
If nHdlSG1 < 0
	MsgBox("Falha na criação do arquivo de log: "+AllTrim(cPathSG1)+". Contate o Administrador.")
	Return
Endif

// Cabeçalho do arquivo
cTexto := "Item;QTY;Part Number;Level"+ENTER
fWrite(nHdlSG1,cTexto)

DbSelectArea("TMP")
DbSetOrder(2)
TMP->(DbGotop())
While !Eof()
	cTexto := AllTrim(STR(Val(TMP->TM_SEQUEN)))+";"+AllTrim(STR(TMP->TM_QUANT))+";"+AllTrim(TMP->TM_PRODUT)+";"+AllTrim(TMP->TM_NIVEL)+ENTER
	fWrite(nHdlSG1,cTexto)
	TMP->(DbSkip())
Enddo

fClose(nHdlSG1)
MsgAlert("Arquivo gerado com sucesso:"+cPathSG1)

Return

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

Static Function fFileSize(xHandle)

Local nLength := FSEEK(xHandle,0,2)
FSEEK(nHandle,0)

Return(nLength)

Static Function pTrab01()

Local _aTmp  := {}
Local zAlias := "TMP"

oTempTable := FWTemporaryTable():New( zAlias )

AAdd ( _aTmp, {"TM_PRODUT" , "C", TamSx3("B1_COD")[1], 00} )
AAdd ( _aTmp, {"TM_DESCRI" , "C", 250, 00} )
AAdd ( _aTmp, {"TM_TIPO"   , "C", 002, 00} )
AAdd ( _aTmp, {"TM_UM"     , "C", 002, 00} )
AAdd ( _aTmp, {"TM_LOCPAD" , "C", 002, 00} )
AAdd ( _aTmp, {"TM_GRUPO"  , "C", 004, 00} )
AAdd ( _aTmp, {"TM_ORIGEM" , "C", 001, 00} )
AAdd ( _aTmp, {"TM_QE"     , "N", 005, 00} )
AAdd ( _aTmp, {"TM_EMIN"   , "N", 005, 00} )
AAdd ( _aTmp, {"TM_ESTSEG" , "N", 005, 00} )
AAdd ( _aTmp, {"TM_PE"     , "N", 005, 00} )
AAdd ( _aTmp, {"TM_TIPE"   , "C", 001, 00} )
AAdd ( _aTmp, {"TM_LE"     , "N", 005, 00} )
AAdd ( _aTmp, {"TM_LM"     , "N", 005, 00} )
AAdd ( _aTmp, {"TM_TOLER"  , "N", 005, 00} )
AAdd ( _aTmp, {"TM_MRP"    , "C", 001, 00} )
AAdd ( _aTmp, {"TM_CONTA"  , "C", 010, 00} )
AAdd ( _aTmp, {"TM_POSIPI" , "C", 010, 00} )
AAdd ( _aTmp, {"TM_P_TIP"  , "C", 001, 00} )
AAdd ( _aTmp, {"TM_PRVALID", "N", 005, 00} )
AAdd ( _aTmp, {"TM_EMAX"   , "N", 005, 00} )
AAdd ( _aTmp, {"TM_PRODSBP", "C", 001, 00} )
AAdd ( _aTmp, {"TM_DESCR02", "C", 250, 00} )
AAdd ( _aTmp, {"TM_ZZGRP2" , "C", 004, 00} )
AAdd ( _aTmp, {"TM_SEQUEN" , "C", 004, 00} )

oTemptable:SetFields( _aTmp )
oTempTable:AddIndex("indice1", {"TM_PRODUT"})
oTempTable:AddIndex("indice2", {"TM_SEQUEN"})
oTempTable:Create()

Return

Static Function pTrab02()

Local _aTmp  := {}
Local zAlias := "TMP"

oTempTable := FWTemporaryTable():New( zAlias )

AAdd ( _aTmp, {"TM_NIVEL"  , "C", 002, 00} )
AAdd ( _aTmp, {"TM_PRODUT" , "C", TamSx3("B1_COD")[1], 00} )
AAdd ( _aTmp, {"TM_CODPAI" , "C", 254, 00} )
AAdd ( _aTmp, {"TM_QUANT"  , "N", 011, 02} )
AAdd ( _aTmp, {"TM_SEQUEN" , "C", 004, 00} )

oTemptable:SetFields( _aTmp )
oTempTable:AddIndex("indice1", {"TM_NIVEL", "TM_PRODUT", "TM_CODPAI"})
oTempTable:AddIndex("indice2", {"TM_SEQUEN"})
oTempTable:Create()

Return

User Function VersaoSb1(xCodigo)

Local xRetCod := PadR(xCodigo,TamSx3("B1_COD")[1])
Local xTamCod := Len(xCodigo)

DbSelectArea("SB1")
DbSetOrder(1)
If DbSeek( xFilial("SB1") + xCodigo, .T. )
	While !Eof() .And. SB1->B1_FILIAL == xFilial("SB1") .And. Substr(SB1->B1_COD,1,xTamCod) == xCodigo
		xRetCod := SB1->B1_COD
		SB1->(DbSkip())
	Enddo
Endif

Return(xRetCod)

User Function ConvDescr(cDescr)

Local xRetDes := cDescr

xRetDes := StrTran(xRetDes,"&","AND")
xRetDes := StrTran(xRetDes,"/"," ")
xRetDes := StrTran(xRetDes,'"',"IN")
xRetDes := StrTran(xRetDes,"[ ]","")
xRetDes := StrTran(xRetDes,"[NA ]","")
xRetDes := StrTran(xRetDes,"PART","")
xRetDes := StrTran(xRetDes,"-"," ")
xRetDes := StrTran(xRetDes,"I- DUMMY"," ")
xRetDes := StrTran(xRetDes,"I-ASY DUMMY"," ")
xRetDes := StrTran(xRetDes,"in","IN")
xRetDes := StrTran(xRetDes,"_"," ")
xRetDes := StrTran(xRetDes,","," ")
xRetDes := StrTran(xRetDes,"#"," ")
xRetDes := StrTran(xRetDes,"  "," ")
xRetDes := StrTran(xRetDes,'”',"IN")

Return(xRetDes)

#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ U6COM008  ¦ Autor ¦ Fábrica ERPBR    ¦   Data  ¦ Set-2023  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Carga de dados - Produtos.								  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo INTRALOX 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function U6COM008()

Local lOk  := .F.
Private cArquivo := Space(30)
Private lOkFile  := .F.
Private cEOL     := CHR(13)+CHR(10)
Private nBytes   := 0
Private nHandle  := 0
Private oProcess

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
		Return
	Endif

	If MsgYesNo("Confirma o processamento - Atualiza dados Produtos ?","Aviso","INFO")
		oProcess := MsNewProcess():New( { | lEnd | lOk := ProcImp() }, "Atualizando dados", "Aguarde, processando ...", .F. )
		oProcess:Activate()
	Endif

	fClose(nHandle)

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ProcImp  ¦ Autor  ¦ Fabrica ERPBR     ¦ Data ¦ Set-2023	  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Processamento da importação.								  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo INTRALOX										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ProcImp()

Local nCountLin := 0
Local cEOL := CHR(13)+CHR(10)

nTamArq := fFileSize(nHandle)
oProcess:SetRegua1(nTamArq/27)
While ( !Empty((cString := fReadFile(nHandle,nTamArq,0,@nBytes))) )
	
	nCountLin += 1
	oProcess:IncRegua1("Analisando arquivo csv..")

	// Fim de Arquivo
	If Len(cString) < 3
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
	// [01] - Filial
	// [02] - Código
	// [03] - Lote Econômico
	// [04] - Lote Mínimo
	// [05] - Prazo Entrega
	// [06] - Grupo2
	// [07] - Estoque Segurança
	// [08] - Preço Venda

	If Len(aLinha) == 7
		AAdd(aLinha,"0.00")
	Endif

	If Len(aLinha) < 8
		MsgInfo("Atenção..., Estrutura do arquivo CSV inválida na linha "+AllTrim(STR(nCountLin))+" ("+AllTrim(STR(Len(aLinha)))+" posições)."+cEOL+"O layout deve conter 8 posições.")
		Return
	Endif
	
	If Len(aLinha) > 0

		zFilial := aLinha[1]
		zProdut := PadR(aLinha[2],15)

		zLotEco := StrTran(aLinha[3],".","")
		zLotEco := StrTran(zLotEco,",",".")
		zLotEco := Val(zLotEco)

		zLotMin := StrTran(aLinha[4],".","")
		zLotMin := StrTran(zLotMin,",",".")
		zLotMin := Val(zLotMin)

		zPrzEnt := Val(aLinha[5])
		zGrupo2 := PadR(aLinha[6],4)
		zEstSeg := Val(aLinha[7])

		zPrcVen := StrTran(aLinha[8],".","")
		zPrcVen := StrTran(zPrcVen,",",".")
		zPrcVen := Val(zPrcVen)

		DbSelectArea("SB1")
		DbSetOrder(1)
		If !DbSeek( xFilial("SB1") + zProdut )
			MsgInfo("Produto inválido: "+zProdut)
			Loop
		Endif

		DbSelectArea("SBM")
		DbSetOrder(1)
		If !DbSeek( xFilial("SBM") + zGrupo2 )
			MsgInfo("Grupo2 inválido: "+zGrupo2)
			Loop
		Endif

		DbSelectArea("SB1")
		DbSetOrder(1)
		If DbSeek( xFilial("SB1") + zProdut )
			RecLock("SB1",.F.)
			If zLotEco > 0
				SB1->B1_LE := zLotEco
			Endif
			If zLotMin > 0
				SB1->B1_LM := zLotMin
			Endif
			If zPrzEnt > 0
				SB1->B1_PE := zPrzEnt
				SB1->B1_TIPE := "D"
			Endif
			If !Empty(zGrupo2)
				SB1->B1_ZZGRP2 := zGrupo2
			Endif
			If zEstSeg > 0
				SB1->B1_ESTSEG := zEstSeg
			Endif
			If zPrcVen > 0
				SB1->B1_PRV1 := zPrcVen
			Endif
			MsUnLock()
		Endif

	Endif
		
Enddo

MsgInfo("Processamento concluído.")
	
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

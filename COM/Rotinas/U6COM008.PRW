#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ U6COM008  ¦ Autor ¦ Fábrica ERPBR    ¦   Data  ¦ Set-2023  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Carga de dados - Produtos.								  ¦¦¦
¦¦¦          ¦ Mrp Memória - 21/11/2024.								  ¦¦¦
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

	If MsgYesNo("Confirma o processamento - Atualiza dados Produtos p/ MRP ?","Aviso","INFO")
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
	// [01] - Código             | B1_COD
	// [02] - Lote Econômico     | B1_LE
	// [03] - Lote Mínimo        | B1_LM
	// [04] - Prazo Entrega      | B1_PE
	// [05] - Grupo2             | B1_ZZGRP2
	// [06] - Estoque Segurança  | B1_ESTSEG
	// [07] - Preço Venda        | B1_PRV1
	// [08] - Ponto de Pedido    | B1_EMIN
	// [09] - Qtd Embalagem      | B1_QE
	// [10] - Atende necessidade | B1_PRODSBP | P=Produzindo C=Comprando

	If Len(aLinha) < 10
		MsgInfo("Atenção..., Estrutura do arquivo CSV inválida na linha "+AllTrim(STR(nCountLin))+" ("+AllTrim(STR(Len(aLinha)))+" posições)."+cEOL+"O layout deve conter 10 posições.")
		Return
	Endif
	
	If Len(aLinha) > 0

		zProdut := PadR(aLinha[1],TamSx3("B1_COD")[1])

		zLotEco := StrTran(aLinha[2],".","")
		zLotEco := StrTran(zLotEco,",",".")
		zLotEco := Val(zLotEco)

		zLotMin := StrTran(aLinha[3],".","")
		zLotMin := StrTran(zLotMin,",",".")
		zLotMin := Val(zLotMin)

		zPrzEnt := Val(aLinha[4])
		zGrupo2 := PadR(aLinha[5],TamSx3("BM_GRUPO")[1])

		zEstSeg := StrTran(aLinha[6],".","")
		zEstSeg := StrTran(zEstSeg,",",".")
		zEstSeg := Val(zEstSeg)

		zPrcVen := StrTran(aLinha[7],".","")
		zPrcVen := StrTran(zPrcVen,",",".")
		zPrcVen := Val(zPrcVen)

		zPontoP := StrTran(aLinha[8],".","")
		zPontoP := StrTran(zPontoP,",",".")
		zPontoP := Val(zPontoP)

		zQtdEmb := Val(aLinha[9])
		zAtende := IIf(aLinha[10]=="P","P","C")

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
			SB1->B1_LE      := zLotEco
			SB1->B1_LM      := zLotMin
			SB1->B1_PE      := zPrzEnt
			SB1->B1_TIPE    := "D"
			SB1->B1_ZZGRP2  := zGrupo2
			SB1->B1_ESTSEG  := zEstSeg
			SB1->B1_PRV1    := zPrcVen
			SB1->B1_EMIN    := zPontoP
			SB1->B1_QE      := zQtdEmb
			SB1->B1_PRODSBP := zAtende
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

#include "protheus.ch"
#include "rwmake.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ U6COM007  ¦ Autor ¦ Fábrica ERPBR    ¦   Data  ¦ Jul-2023  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Carga de dados - Fornecedores.							  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo INTRALOX 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function U6COM007()

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

	If MsgYesNo("Confirma o processamento - Atualiza dados Fornecedores ?","Aviso","INFO")
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
¦¦¦Função    ¦ ProcImp  ¦ Autor  ¦ Fabrica ERPBR     ¦ Data ¦ Jul-2023	  ¦¦¦
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
	// [01] - Código
	// [02] - Razão
	// [03] - Endereço
	// [04] - Bairro
	// [05] - CEP
	// [06] - Estado
	// [07] - Nome Fantasia
	// [08] - Município
	// [09] - Cód.Município
	// [10] - Tipo
	// [11] - CNPJ
	// [12] - Telefone
	// [13] - Celular
	// [14] - I.E.
	// [15] - Email
	// [16] - DDD
	// [17] - Email Receb.
	// [18] - Email Pcp
	// [19] - Cond.Pagto.
	// [20] - Contato
	// [21] - Tipo Frete

	If Len(aLinha) < 21
		MsgInfo("Atenção..., Estrutura do arquivo CSV inválida ("+AllTrim(STR(Len(aLinha)))+" posições)."+cEOL+"O layout deve conter 21 posições.")
		Return
	Endif
	
	If Len(aLinha) > 0

		zCodFor := PadR(aLinha[1],6)
		zNomFor := AllTrim(aLinha[2])
		zEndere := AllTrim(aLinha[3])
		zBairro := AllTrim(aLinha[4])
		zCepFor := StrTran(aLinha[5],"-","")
		zEstFor := AllTrim(aLinha[6])
		zNreduz := AllTrim(aLinha[7])
		zMunici := AllTrim(aLinha[8])
		zCodMun := AllTrim(aLinha[9])
		zTipFor := Substr(aLinha[10],1,1)
		zCgcFor := StrTran(aLinha[11],".","")
		zCgcFor := StrTran(zCgcFor,"/","")
		zCgcFor := StrTran(zCgcFor,"-","")
		zTelefo := StrTran(aLinha[12],"-","")
		zCelula := StrTran(aLinha[13]," ","")
		zInscrE := StrTran(aLinha[14],".","")
		zEmlFor := Lower(AllTrim(aLinha[15]))
		zDDDFor := AllTrim(aLinha[16])
		zEmlRec := Lower(AllTrim(aLinha[17]))
		zEmlPcp := Lower(AllTrim(aLinha[18]))
		zCondPg := AllTrim(aLinha[19])
		zContat := AllTrim(aLinha[20])
		zTpFret := Substr(aLinha[21],1,1)

		DbSelectArea("SA2")
		DbSetOrder(1)
		If !DbSeek( xFilial("SA2") + zCodFor )
			MsgInfo("Fornecedor inválido: "+zCodfor)
			Loop
		Endif

		DbSelectArea("CC2")
		DbSetOrder(1)
		If !DbSeek( xFilial("CC2") + zEstFor + zCodMun )
			MsgInfo("Cód.Município inválido: "+zEstFor+"-"+zCodMun)
			Loop
		Endif

		DbSelectArea("SE4")
		DbSetOrder(1)
		If !DbSeek( xFilial("SE4") + zCondPg )
			MsgInfo("Cond.pagamento inválida: "+zCondPg)
			Loop
		Endif

		If !(zTipFor $("J,F"))
			MsgInfo("Tipo Fornecedor inválido: "+zTipFor)
			Loop
		Endif

		If !(zTpFret $("C,F"))
			MsgInfo("Tipo Frete inválido: "+zTpFret)
			Loop
		Endif

		DbSelectArea("SA2")
		DbSetOrder(1)
		If DbSeek( xFilial("SA2") + zCodFor )
			RecLock("SA2",.F.)
			SA2->A2_NOME    := zNomFor
			SA2->A2_END     := zEndere
			SA2->A2_BAIRRO  := zBairro
			SA2->A2_CEP     := zCepFor
			SA2->A2_EST     := zEstFor
			SA2->A2_NREDUZ  := zNReduz
			SA2->A2_MUN     := zMunici
			SA2->A2_COD_MUN := zCodMun
			SA2->A2_TIPO    := zTipFor
			SA2->A2_CGC     := zCgcFor
			SA2->A2_TEL     := zTelefo
			SA2->A2_TELEX   := zCelula
			SA2->A2_INSCR   := zInscrE
			SA2->A2_EMAIL   := zEmlFor
			SA2->A2_DDD     := zDDDFor
			SA2->A2_ZEMLREC := zEmlRec
			SA2->A2_ZEMLPCP := zEmlPcp
			SA2->A2_COND    := zCondPg
			SA2->A2_CONTATO := zContat
			SA2->A2_ZZTPFRT := zTpFret
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

#include "protheus.ch"
#include "totvs.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ U6COM001  ¦ Autor ¦ Fábrica ERPBR   ¦   Data   ¦ Abr/2023  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Importação da tabela de preços fornecedor via CSV.		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo INTRALOX 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function U6COM001()

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

	If MsgYesNo("Confirma o processamento: Tabela de Preços ?","Aviso","INFO")
		oProcess := MsNewProcess():New( { | lEnd | lOk := ProcImp() }, "Importação em progresso", "Aguarde, processando ...", .F. )
		oProcess:Activate()
	Endif

	fClose(nHandle)

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ProcImp   ¦ Autor ¦ Fábrica ERPBR   ¦   Data   ¦ Abr/2023  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Importação da solicitação de compras via CSV.			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo INTRALOX 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ProcImp()

Local nCount := 0
Local aCabec := {}
Local aItem  := {}
Local aItens := {}
Local aLinha := {}
Local lAbort := .F.

Private lMsHelpAuto := .F. // Determina se as mensagens de help devem ser direcionadas para o arq. de log
Private lMsErroAuto := .F. // Determina se houve alguma inconsistencia na execucao da rotina

nTamArq := fFileSize(nHandle)
oProcess:SetRegua1(160)
While ( !Empty((cString := fReadFile(nHandle,nTamArq,0,@nBytes))) )
	
	nCount += 1
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
	// [01] - Cnpj
	// [02] - Código Tabela
	// [03] - Descrição Tabela
	// [04] - Vigência inicial
	// [05] - Vigência final
	// [06] - Cond.Pagto.
	// [07] - Produto
	// [08] - Preço
	// [09] - Vigência inicial Item

	If Len(aLinha) == 3
		AAdd(aLinha,"")
	Endif

	If Len(aLinha) < 9
		MsgInfo("Atenção..., Estrutura do arquivo CSV inválida ("+AllTrim(STR(Len(aLinha)))+" posições)."+cEOL+"O layout deve conter 9 posições.")
		Return
	Endif
	
	If Len(aLinha) > 0

		zCnpj   := PadR(aLinha[1],14)
		zCodTab := PadR(aLinha[2],3)
		zDesTab := AllTrim(aLinha[3])
		zVigIni := CtoD(aLinha[4])
		zVigFim := CtoD(aLinha[5])
		zCondPg := PadR(aLinha[6],3)
		zProdut := PadR(aLinha[7],15)
		zPreco  := StrTran(AllTrim(aLinha[8]),".","")
		zPreco  := StrTran(zPreco,",",".")
		zPreco  := Val(zPreco)
		zVigIte := CtoD(aLinha[9])

		// Validações
		lTudoOk := .T.

		DbSelectArea("SA2")
		DbSetOrder(3)
		If !DbSeek( xFilial("SA2") + zCnpj )
			lTudoOk := .F.
			MsgAlert("Linha "+AllTrim(STR(nCount))+": CNPJ "+AllTrim(zCnpj)+" não cadastrado.")
		Else
			DbSelectArea("AIA")
			DbSetOrder(1)
			If DbSeek( xFilial("AIA") + SA2->(A2_COD+A2_LOJA) + zCodTab )
				lTudoOk := .F.
				MsgAlert("Linha "+AllTrim(STR(nCount))+": Tabela "+AllTrim(zCodTab)+" já cadastrada p/ o fornecedor "+AllTrim(SA2->A2_NOME)+".")
			Endif
		Endif

		If Empty(zDesTab)
			lTudoOk := .F.
			MsgAlert("Linha "+AllTrim(STR(nCount))+": Descrição da Tabela "+AllTrim(zCodTab)+" não informada.")
		Endif

		If Empty(zVigIni)
			lTudoOk := .F.
			MsgAlert("Linha "+AllTrim(STR(nCount))+": Vigência inicial "+AllTrim(aLinha[4])+" inválida.")
		Endif

		If Empty(zVigFim)
			lTudoOk := .F.
			MsgAlert("Linha "+AllTrim(STR(nCount))+": Vigência final "+AllTrim(aLinha[5])+" inválida.")
		Endif

		If !Empty(zCondPg)
			DbSelectArea("SE4")
			DbSetOrder(1)
			If !DbSeek( xFilial("SE4") + zCondPg )
				lTudoOk := .F.
				MsgAlert("Linha "+AllTrim(STR(nCount))+": Cond.Pagto. "+AllTrim(zCondPg)+" não cadastrada.")
			Endif
		Endif

		DbSelectArea("SB1")
		DbSetOrder(1)
		If !DbSeek( xFilial("SB1") + zProdut )
			lTudoOk := .F.
			MsgAlert("Linha "+AllTrim(STR(nCount))+": Produto "+AllTrim(zProdut)+" não cadastrado.")
		Endif

		If zPreco <= 0
			lTudoOk := .F.
			MsgAlert("Linha "+AllTrim(STR(nCount))+": Preço "+AllTrim(STR(zPreco))+" inválido.")
		Endif

		If Empty(zVigIte)
			lTudoOk := .F.
			MsgAlert("Linha "+AllTrim(STR(nCount))+": Vigência Item "+AllTrim(aLinha[9])+" inválida.")
		Endif

		If lTudoOk

			If nCount == 1
				AAdd(aCabec,{"AIA_CODFOR", SA2->A2_COD , })   
				AAdd(aCabec,{"AIA_LOJFOR", SA2->A2_LOJA, }) 
				AAdd(aCabec,{"AIA_CODTAB", zCodTab     , })   
				AAdd(aCabec,{"AIA_DESCRI", zDesTab     , }) 
				AAdd(aCabec,{"AIA_DATDE" , zVigIni     , })
				AAdd(aCabec,{"AIA_DATATE", zVigFim     , }) 
				AAdd(aCabec,{"AIA_CONDPG", zCondPg     , }) 
			Endif

			aItem := {}			
			AAdd(aItem,{"AIB_ITEM"  , StrZero(nCount,4), Nil})
			AAdd(aItem,{"AIB_CODPRO", zProdut          , Nil})
			AAdd(aItem,{"AIB_DESCRI", SB1->B1_DESC     , Nil})
			AAdd(aItem,{"AIB_PRCCOM", zPreco           , Nil})
			AAdd(aItem,{"AIB_DATVIG", zVigIte          , Nil})
			AAdd(aItens,aItem)		
			
		Else

			lAbort := .T.
			Exit

		Endif	

	Endif
		
Enddo

If !lAbort

	DbSelectArea("SA2")
	DbSetOrder(1)

	MSExecAuto({|x,y,z| COMA010(x,y,z)}, 3, aCabec, aItens)  
	If !lMsErroAuto
		MsgInfo("Incluído com sucesso !")
	Else			
		MostraErro()
	Endif

Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ fReadFile ¦ Autor ¦ Fábrica ERPBR   ¦   Data   ¦ Abr/2023  ¦¦¦
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
¦¦¦Programa  ¦ fFileSize ¦ Autor ¦ Fábrica ERPBR   ¦   Data   ¦ Abr/2023  ¦¦¦
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

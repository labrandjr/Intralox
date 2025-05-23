#include "protheus.ch"
#include "totvs.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    � U6COM002  � Autor � F�brica ERPBR   �   Data   � Abr/2023  ���
��+----------+------------------------------------------------------------���
���Descricao � Importa��o da solicita��o de compras via CSV.			  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo INTRALOX 										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function U6COM002()

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
		MsgAlert("Arquivo n�o encontrado.")
	Endif
Else
	MsgAlert("Arquivo n�o selecionado.")
Endif

If lOkFile

	nHandle := fOpen(cArquivo,2)

	If nHandle == -1
		Alert("Problema na abertura do arquivo "+cArquivo+".")
		Return
	Endif

	If MsgYesNo("Confirma o processamento: Solicita��o de Compras ?","Aviso","INFO")
		oProcess := MsNewProcess():New( { | lEnd | lOk := ProcImp() }, "Importa��o em progresso", "Aguarde, processando ...", .F. )
		oProcess:Activate()
	Endif

	fClose(nHandle)

Endif

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun��o    � ProcImp   � Autor � F�brica ERPBR   �   Data   � Abr/2023  ���
��+----------+------------------------------------------------------------���
���Descricao � Importa��o da solicita��o de compras via CSV.			  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo INTRALOX 										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function ProcImp()

Local nCount := 0
Local aCabec := {}
Local aItem  := {}
Local aItens := {}
Local aLinha := {}
Local zDoc   := ""
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
	// [01] - Produto
	// [02] - Quantidade
	// [03] - Data necessidade
	// [04] - Observa��es
	// [05] - Fornecedor (opcional)
	// [06] - Loja (opcional)

	If Len(aLinha) == 3
		AAdd(aLinha,"")
	Endif

	If Len(aLinha) < 4
		MsgInfo("Aten��o..., Estrutura do arquivo CSV inv�lida ("+AllTrim(STR(Len(aLinha)))+" posi��es)."+cEOL+"O layout deve conter pelo menos 4 posi��es.")
		Return
	Endif

	If Len(aLinha) == 4
		AAdd(aLinha,"")
		AAdd(aLinha,"")
	Endif

	If Len(aLinha) == 5
		AAdd(aLinha,"")
	Endif

	If Len(aLinha) > 0

		zProd := PadR(aLinha[1],15)
		zQtde := StrTran(AllTrim(aLinha[2]),".","")
		zQtde := StrTran(zQtde,",",".")
		zQtde := Val(zQtde)
		zDtNc := CtoD(aLinha[3])
		zObsv := AllTrim(aLinha[4])
		zForn := PadR(aLinha[5],10)
		zLoja := PadR(aLinha[6],2)

		// Valida��es
		lTudoOk := .T.

		DbSelectArea("SB1")
		DbSetOrder(1)
		If !DbSeek( xFilial("SB1") + zProd )
			lTudoOk := .F.
			MsgAlert("Linha "+AllTrim(STR(nCount))+": Produto "+AllTrim(zProd)+" n�o cadastrado.")
		Endif

		If zQtde <= 0
			lTudoOk := .F.
			MsgAlert("Linha "+AllTrim(STR(nCount))+": Quantidade "+AllTrim(STR(zQtde))+" inv�lida.")
		Endif

		If Empty(zDtNc)
			lTudoOk := .F.
			MsgAlert("Linha "+AllTrim(STR(nCount))+": Dt.Necessidade "+AllTrim(aLinha[3])+" inv�lida.")
		Endif

		If !Empty(zForn)
			DbSelectArea("SA2")
			DbSetOrder(1)
			If !DbSeek( xFilial("SA2") + zForn + zLoja )
				lTudoOk := .F.
				MsgAlert("Linha "+AllTrim(STR(nCount))+": Fornecedor "+AllTrim(zForn)+"-"+AllTrim(zLoja)+" n�o cadastrado.")
			Endif
		Endif	

		If lTudoOk

			aItem := {}			
			AAdd(aItem,{"C1_ITEM"   , StrZero(nCount,4), Nil})
			AAdd(aItem,{"C1_PRODUTO", zProd            , Nil})
			AAdd(aItem,{"C1_QUANT"  , zQtde            , Nil})
			AAdd(aItem,{"C1_DATPRF" , zDtNc            , Nil})
			AAdd(aItem,{"C1_OBS"    , zObsv            , Nil})
			If !Empty(zForn)
				AAdd(aItem,{"C1_FORNECE", zForn        , Nil})
				AAdd(aItem,{"C1_LOJA"   , zLoja        , Nil})
			Endif
			AAdd(aItens,aItem)		
			
		Else

			lAbort := .T.
			Exit

		Endif	

	Endif
		
Enddo

If !lAbort

	zDoc := GetSXENum("SC1","C1_NUM")		
	SC1->(DbSetOrder(1))		
	While SC1->(DbSeek(xFilial("SC1")+zDoc))			
		ConfirmSX8()			
		zDoc := GetSXENum("SC1","C1_NUM")		
	EndDo					
	AAdd(aCabec,{"C1_NUM"    , zDoc      })		
	AAdd(aCabec,{"C1_SOLICIT", cUserName })		
	AAdd(aCabec,{"C1_EMISSAO", dDataBase })		

	MsExecAuto({|x,y| MATA110(x,y)}, aCabec, aItens)		
	If !lMsErroAuto
		MsgInfo("Inclu�do com sucesso !")
	Else			
		MostraErro()
	Endif

Endif

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � fReadFile � Autor � F�brica ERPBR   �   Data   � Abr/2023  ���
��+----------+------------------------------------------------------------���
���Descricao � Efetua leitura do arquivo e retorna conteudo da linhaa.	  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo INTRALOX										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Programa  � fFileSize � Autor � F�brica ERPBR   �   Data   � Abr/2023  ���
��+----------+------------------------------------------------------------���
���Descricao � Obtem o tamanho do arquivo texto.						  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo INTRALOX										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function fFileSize(xHandle)

Local nLength := FSEEK(xHandle,0,2)
FSEEK(nHandle,0)

Return(nLength)

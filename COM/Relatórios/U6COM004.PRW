#include "protheus.ch"
#include "tbiconn.ch"
#include "colors.ch"
#include "rptdef.ch"
#include "FWPrintSetup.ch"

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Funcao    � PDFPEDC   � Autor �  Fabrica ERPBR    � Data � 18/04/2023  ���
��+----------+------------------------------------------------------------���
���Descricao � Pedido de Compra modelo Pdf.								  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo INTRALOX										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function PDFPEDC(aPedido,cPathPdf,lExibe)

Local oFont08  := TFont():New("Arial",08,08,,.F.,,,,.T.,.F.)
Local oFont09N := TFont():New("Arial",09,09,,.T.,,,,.T.,.F.)
Local oFont10  := TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
Local oFont10N := TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
Local oFont12  := TFont():New("Arial",12,12,,.F.,,,,.T.,.F.)
Local zPathPDF := AllTrim(cPathPdf)+"\"
Local zValIcm  := 0
Local zValIpi  := 0
Local zValDes  := 0
Local zValDsp  := 0
Local zValSeg  := 0
Local zValFre  := 0
Local zValTot  := 0
Local zPdf     := ""
Local zTotFol  := 1
Local lModDes  := .T. // Modelo de impress�o que exibe o pre�o unit�rio com desconto
Local zTpFret  := ""
Local pdc, _pdc
Private opdc

If !(FWCodEmp() $("99,U6"))
	MsgAlert("Empresa n�o autorizada: "+FWCodEmp())
	Return
Endif

If Len(aPedido) == 0
	MsgAlert("Sem dados para gera��o do Pdf.")
	Return
Endif

DbSelectArea("SC7")
DbSetOrder(1)
DbSeek( aPedido[1][1] + aPedido[1][2] )

DbSelectArea("SA2")
DbSetOrder(1)
DbSeek( xFilial("SA2") + SC7->C7_FORNECE + SC7->C7_LOJA )

zPdf := SC7->C7_NUM+" "+AllTrim(SA2->A2_NOME)

zPdf := StrTran(zPdf,".","")
zPdf := StrTran(zPdf,",","")
zPdf := StrTran(zPdf,"-","")
zPdf := StrTran(zPdf,"_","")
zPdf := StrTran(zPdf,";","")
zPdf := StrTran(zPdf,"&","")
zPdf := StrTran(zPdf,"/","")
zPdf := StrTran(zPdf,"\","")
zPdf := StrTran(zPdf,"(","")
zPdf := StrTran(zPdf,")","")
zPdf := StrTran(zPdf,"{","")
zPdf := StrTran(zPdf,"}","")
zPdf := StrTran(zPdf,"[","")
zPdf := StrTran(zPdf,"]","")
zPdf := StrTran(zPdf,"�","")
zPdf := StrTran(zPdf,"@","")
zPdf := StrTran(zPdf,"%","")
zPdf := StrTran(zPdf,"$","")
zPdf := StrTran(zPdf,"#","")
zPdf := StrTran(zPdf,"!","")
zPdf := StrTran(zPdf,"?","")
zPdf := StrTran(zPdf,CHR(13),"")
zPdf := StrTran(zPdf,CHR(10),"")

// Paginas
xLin := 210
For _pdc := 1 to Len(aPedido)
	//
	DbSelectArea("SC7")
	DbSetOrder(1)
	DbSeek( aPedido[_pdc][1] + aPedido[_pdc][2] + aPedido[_pdc][3] )
	//
	If xLin > 530
		xLin := 210
		zTotFol += 1
	Endif
	xLin += 15
	//
	lImpLn2 := .F.
	zDescr2 := AllTrim(Substr(SC7->C7_DESCRI,36))
	zObserv := Substr(SC7->C7_OBS,1,130)
	If !Empty(zDescr2)
		lImpLn2 := .T.
		xLin += 15
	Endif
	If !Empty(zObserv)
		lImpLn2 := .T.
		xLin += 15
	Endif
	If !lImpLn2
		xLin += 15
	Endif
	//
Next _pdc
xLin += 15
xLin += 10
xLin += 15
If xLin > 500
	zTotFol += 1
Endif
zTotFol += 3

opdc:=FWMSPrinter():New(zPdf,IMP_PDF,.F.,zPathPDF,.T.,,@opdc,,,,,lExibe)
opdc:SetResolution(72)
opdc:SetLandscape()
opdc:SetPaperSize(DMPAPER_A4)
opdc:SetMargin(60,60,60,60)
opdc:cPathPDF := zPathPDF

opdc:StartPage()
pdcCab(1,zTotFol,.T.)

zEntreg := CtoD("")
zFolha  := 1
zLin    := 210
For pdc := 1 to Len(aPedido)
	If zLin > 530
		opdc:Line(zLin, 0000, zLin, 0800)
		opdc:EndPage()
		opdc:StartPage()
		zFolha += 1
		pdcCab(zFolha,zTotFol,.T.)
		zLin := 210
	Endif
	//
	DbSelectArea("SC7")
	DbSetOrder(1)
	DbSeek( aPedido[pdc][1] + aPedido[pdc][2] + aPedido[pdc][3] )
	If Empty(zTpFret)
		zTpFret := SC7->C7_TPFRETE
	Endif
	//
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek( xFilial("SB1") + SC7->C7_PRODUTO )
	//
	opdc:Say(zLin, 0000, SC7->C7_ITEM,oFont10,,IIf(GetMv("MV_IMPXML"),CLR_HRED,CLR_BLACK))
	opdc:Say(zLin, 0030, SC7->C7_PRODUTO,oFont10)
	opdc:Say(zLin, 0110, Transform(SC7->C7_QUANT, PesqPict("SC7","C7_QUANT")),oFont10)
	opdc:Say(zLin, 0190, SC7->C7_UM,oFont10)
	opdc:Say(zLin, 0240, Substr(SC7->C7_DESCRI,1,35),oFont10)
	If !lModDes
		opdc:Say(zLin, 0420, Transform(SC7->C7_PRECO, PesqPict("SC7","C7_PRECO")),oFont10)
	Else
		zPrecoLiq := SC7->((C7_TOTAL-C7_VLDESC) / C7_QUANT)
		opdc:Say(zLin, 0420, Transform(zPrecoLiq, PesqPict("SC7","C7_PRECO")),oFont10)
	Endif	
	If !lModDes
		opdc:Say(zLin, 0490, Transform(SC7->C7_TOTAL, PesqPict("SC7","C7_TOTAL")),oFont10)
	Else
		zTotalLiq := SC7->(C7_TOTAL-C7_VLDESC)
		opdc:Say(zLin, 0490, Transform(zTotalLiq, PesqPict("SC7","C7_TOTAL")),oFont10)
	Endif	
	opdc:Say(zLin, 0580, Transform(SC7->C7_PICM, PesqPict("SC7","C7_PICM")),oFont10)
	opdc:Say(zLin, 0645, Transform(SC7->C7_IPI, PesqPict("SC7","C7_IPI")),oFont10)
	opdc:Say(zLin, 0705, SC7->C7_LOCAL,oFont10)
	opdc:Say(zLin, 0750, DtoC(SC7->C7_DATPRF),oFont10)
	zLin += 15
	opdc:Say(zLin, 0030, AllTrim(SB1->B1_POSIPI),oFont10)
	//
	lImpLn2 := .F.
	zDescr2 := AllTrim(Substr(SC7->C7_DESCRI,36))
	zObserv := Substr(SC7->C7_OBS,1,130)
	If !Empty(zDescr2)
		lImpLn2 := .T.
		opdc:Say(zLin, 0240, zDescr2,oFont10)
		zLin += 15
	Endif
	If !Empty(zObserv)
		lImpLn2 := .T.
		opdc:Say(zLin, 0240, zObserv,oFont08)
		zLin += 15
	Endif
	If !lImpLn2
		zLin += 15
	Endif
	//
	zValIcm += SC7->C7_VALICM
	zValIpi += SC7->C7_VALIPI
	zValDes += SC7->C7_VLDESC
	zValDsp += SC7->C7_DESPESA
	zValSeg += SC7->C7_SEGURO
	zValFre += SC7->C7_VALFRE
	zValTot += SC7->C7_TOTAL
	//
	If Empty(zEntreg) .Or. SC7->C7_DATPRF > zEntreg
		zEntreg := SC7->C7_DATPRF
	Endif
	//
Next pdc
opdc:Line(zLin, 0000, zLin, 0800)
zLin += 15
opdc:Say(zLin, 0000, "ICMS: "+AllTrim(Transform(zValIcm, PesqPict("SC7","C7_VALICM"))),oFont10N)
opdc:Say(zLin, 0120, "IPI: "+AllTrim(Transform(zValIpi, PesqPict("SC7","C7_VALIPI"))),oFont10N)
opdc:Say(zLin, 0240, "Desconto: "+AllTrim(Transform(zValDes, PesqPict("SC7","C7_VLDESC"))),oFont10N)
opdc:Say(zLin, 0360, "Despesas: "+AllTrim(Transform(zValDsp, PesqPict("SC7","C7_DESPESA"))),oFont10N)
opdc:Say(zLin, 0480, "Seguro: "+AllTrim(Transform(zValSeg, PesqPict("SC7","C7_SEGURO"))),oFont10N)
opdc:Say(zLin, 0600, "Frete: "+AllTrim(Transform(zValFre, PesqPict("SC7","C7_VALFRE"))),oFont10N)
opdc:Say(zLin, 0710, "Valor Total: "+AllTrim(Transform(((zValTot+zValIpi+zValDsp+zValSeg+zValFre)-zValDes), PesqPict("SC7","C7_TOTAL"))),oFont10N)
zLin += 10
opdc:Line(zLin, 0000, zLin, 0800)
zLin += 15

If zLin > 500
	opdc:EndPage()
	opdc:StartPage()
	zFolha += 1
	pdcCab(zFolha,zTotFol,.F.)
	zLin := 185
Endif

nMoeda  := IIf(SC7->C7_MOEDA > 1, SC7->C7_MOEDA, 1)
zMoedPc := AllTrim(GetMv("MV_MOEDA"+AllTrim(STR(nMoeda))))
zTaxaPc := IIf(SC7->C7_MOEDA > 1, SC7->C7_TXMOEDA, 1)
zEndEnt := AllTrim(SM0->M0_ENDENT)+" "+AllTrim(SM0->M0_BAIRENT)+" - "+AllTrim(SM0->M0_CIDENT)+"/"+AllTrim(SM0->M0_ESTENT)+" - CEP: "+Transform(SM0->M0_CEPENT,"@R 99999-999")+" - Telefone: +55 (19) 2516-8900"
zEndEnt := Upper(zEndEnt)
zEndCob := AllTrim(SM0->M0_ENDCOB)+" "+AllTrim(SM0->M0_BAIRCOB)+" - "+AllTrim(SM0->M0_CIDCOB)+"/"+AllTrim(SM0->M0_ESTCOB)+" - CEP: "+Transform(SM0->M0_CEPCOB,"@R 99999-999")+" - Telefone: +55 (19) 2516-8985"
zEndCob := Upper(zEndCob)

DbSelectArea("SE4")
DbSetOrder(1)
DbSeek( xFilial("SE4") + SC7->C7_COND )

If Empty(zTpFret)
	zDsFrete := "N�o Informado"
ElseIf zTpFret == "C"
	zDsFrete := "CIF"
ElseIf zTpFret == "F"
	zDsFrete := "FOB"
ElseIf zTpFret == "T"
	zDsFrete := "Terceiros"
ElseIf zTpFret == "R"
	zDsFrete := "Remetente"
ElseIf zTpFret == "D"
	zDsFrete := "Destinat�rio"
ElseIf zTpFret == "S"
	zDsFrete := "Sem Frete"
Endif

opdc:Say(zLin, 0000, "Valores expressos em: "+zMoedPc + Space(30) + "Tx.Convers�o: "+Transform(zTaxaPc,"@E 9.9999") + Space(30) + "Prazo programado p/ entrega: "+DtoC(zEntreg) + Space(30) + "Cond.Pagamento: "+AllTrim(SE4->E4_DESCRI) + Space(30) + "Tp.Frete: "+zDsFrete,oFont10)
zLin += 15
opdc:Say(zLin, 0000, "Endere�o de entrega: "+zEndEnt,oFont10)
zLin += 15
opdc:Say(zLin, 0000, "Endere�o de cobran�a: "+zEndCob,oFont10)
zLin += 15
opdc:Say(zLin, 0000, "Situa��o do Pedido: "+IIf(SC7->C7_CONAPRO=="L","APROVADO","EM APROVA��O"),oFont10N)
If GetMv("MV_IMPXML")
	zLin += 15
	opdc:Say(zLin, 0000, "Sr.Fornecedor, favor informar as tags do XML <xPed> e <nItemPed>",oFont10N,,CLR_HRED)
Endif
zLin += 10
opdc:Line(zLin, 0000, zLin, 0800)

opdc:EndPage()
opdc:StartPage()
zFolha += 1
opdc:Say(0040, 0660, "Folha: "+AllTrim(STR(zFolha))+" de "+AllTrim(STR(zTotFol)),oFont12)
zLin := 0050

opdc:Box(zLin, 0000, zLin+20, 0800)
opdc:Say(zLin+12, 0220, "TERMOS E CONDI��ES DA ORDEM DE COMPRA DA INTRALOX DO BRASIL LTDA. (COMPRADORA)",oFont10N)

zLin += 0025
opdc:Box(zLin, 0000, zLin+50, 0800)
opdc:Say(zLin+12, 0010, "1. ACEITA��O:",oFont09N)
opdc:Say(zLin+12, 0065, "Salvo indica��o por escrito em contr�rio, o pagamento dos valores devidos pela Compradora � Vendedora est� condicionado � entrega satisfat�ria dos servi�os e/ou produtos em conformidade com o cronograma previsto nesta",oFont08)
opdc:Say(zLin+22, 0010, "ordem de compra. Esta ordem de compra ser� regida �nica e exclusivamente pelos termos e condi��es especificados em seu quadro resumo (p�gina 1), neste Termos e em seus anexos, n�o estando autorizada qualquer altera��o, adi��o e/ou",oFont08)
opdc:Say(zLin+32, 0010, "exclus�o das cl�usulas deste Termo, exceto mediante a assinatura, por ambas as Partes, de termo aditivo. No caso de conflito entre o quadro resumo, estes Termos e seus anexos, prevalecer� o quanto previsto nestes Termos, exceto caso",oFont08)
opdc:Say(zLin+42, 0010, "nele indicado diversamente por escrito.",oFont08)

zLin += 0055
opdc:Box(zLin, 0000, zLin+40, 0800)
opdc:Say(zLin+12, 0010, "2. EMBALAGEM E ENVIO:",oFont09N)
opdc:Say(zLin+12, 0100, "Todos os produtos previstos nesta ordem de compra dever�o ser devidamente preparados, embalados e acondicionados para que sejam entregues � Compradora, a fim de garantir as menores taxas de transporte",oFont08)
opdc:Say(zLin+22, 0010, "e cumprir com as leis aplic�veis e os regulamentos internos da transportadora. Nenhum custo adicional com embalagem, acondicionamento, gradeamento ou transporte ser� suportado pela Compradora, a menos que assim seja expressamente",oFont08)
opdc:Say(zLin+32, 0010, "indicado nesta ordem de compra. Todas as remessas de produtos a serem enviadas � Compradora em um mesmo dia e por uma mesma rota dever�o ser consolidadas em um s� envio.",oFont08)

zLin += 0045
opdc:Box(zLin, 0000, zLin+50, 0800)
opdc:Say(zLin+12, 0010, "3. ENVIO OU ENTREGA:",oFont09N)
opdc:Say(zLin+12, 0095, "O cumprimento dos prazos acordados entre as Partes � fundamental para o adimplemento desta ordem de compra pela Vendedora. Assim, o envio, entrega e execu��o dos servi�os dever�o respeitar o cronograma",oFont08)
opdc:Say(zLin+22, 0010, "e as quantidades exatas previstas na ordem de compra. Se a Vendedora n�o cumprir (ou apresentar ind�cios de que n�o cumprir�) o cronograma fixado entre as Partes, a Vendedora dever�, mediante solicita��o da Compradora, e sem preju�zo",oFont08)
opdc:Say(zLin+32, 0010, "de quaisquer outros direitos ou rem�dios previstos neste Termo e/ou garantidos por lei, utilizar o tipo de envio priorit�rio h�bil a cumprir referido cronograma ou minimizar ao m�ximo o seu atraso. A diferen�a entre o custo do envio",oFont08)
opdc:Say(zLin+42, 0010, "priorit�rio utilizado e o tipo de envio previsto no quadro resumo ser� suportado integralmente pela Vendedora.",oFont08)

zLin += 0055
opdc:Box(zLin, 0000, zLin+30, 0800)
opdc:Say(zLin+12, 0010, "4. INSPE��O:",oFont09N)
opdc:Say(zLin+12, 0060, "Todos os itens est�o sujeitos � inspe��o final e aceita��o, quando do seu recebimento pela Compradora, independentemente de qualquer pagamento ou inspe��o pr�via. A aceita��o de quaisquer itens pela Compradora n�o",oFont08)
opdc:Say(zLin+22, 0010, "alterar� as obriga��es da Vendedora ou os direitos da Compradora e de seus clientes, previstos na cl�usula de 6. GARANTIA ou em qualquer outra disposi��o desta ordem de compra.",oFont08)

zLin += 0035
opdc:Box(zLin, 0000, zLin+40, 0800)
opdc:Say(zLin+12, 0010, "5. REJEI��O:",oFont09N)
opdc:Say(zLin+12, 0060, "A Compradora notificar� a Vendedora se quaisquer itens entregues por for�a desta ordem de compra forem rejeitados, a Compradora poder�, a seu exclusivo crit�rio, solicitar � Vendedora, sua: i) devolu��o, mediante o",oFont08)
opdc:Say(zLin+22, 0010, "reembolso proporcional do valor; ii) substitui��o; ou c) corre��o. Em qualquer dos casos, a Vendedora suportar� integralmente os custos envolvidos, sendo que nenhuma das alternativas ser� adotada automaticamente pela Vendedora,",oFont08)
opdc:Say(zLin+32, 0010, "exceto mediante a aprova��o pr�via e por escrito da Compradora.",oFont08)

zLin += 0045
opdc:Box(zLin, 0000, zLin+40, 0800)
opdc:Say(zLin+12, 0010, "6. GARANTIA:",oFont09N)
opdc:Say(zLin+12, 0060, "A Vendedora garante que todos os bens aqui entregues ser�o comercializ�veis, adequados � sua finalidade espec�fica e livres de defeitos, ocultos ou aparentes. A Vendedora garante que todos os servi�os ser�o executados",oFont08)
opdc:Say(zLin+22, 0010, "com a melhor t�cnica e livres de erros. As garantias sob a responsabilidade da Vendedora poder�o ser reivindicadas pela Compradora e/ou seus clientes, sem quaisquer limita��es ou exclus�o de garantias contratuais ou legais.",oFont08)
opdc:Say(zLin+32, 0010, "A Vendedora garante que os itens fornecidos estar�o em conformidade com as especifica��es, desenhos e descri��es listados, bem como com a(s) amostra(s) fornecida(s) pela Vendedora, se houver.",oFont08)

zLin += 0045
opdc:Box(zLin, 0000, zLin+40, 0800)
opdc:Say(zLin+12, 0010, "7. ALTERA��ES:",oFont09N)
opdc:Say(zLin+12, 0070, "A Compradora poder� fazer altera��es na especifica��o dos servi�os a serem executados ou em bens a serem fabricados a seu pedido, negociando, as Partes, de boa-f�, eventuais aumentos ou redu��es nos pre�os em",oFont08)
opdc:Say(zLin+22, 0010, "raz�o das altera��es. Por outro lado, nenhuma altera��o precisar� ser aceita ou pagamento adicional realizado pela Compradora em decorr�ncia de altera��es unilaterais efetuadas por parte da Vendedora, sendo necess�rio, que referidas",oFont08)
opdc:Say(zLin+32, 0010, "altera��es sejam submetidas � aprecia��o e aprova��o pr�via e por escrito da Compradora.",oFont08)

zLin += 0045
opdc:Box(zLin, 0000, zLin+30, 0800)
opdc:Say(zLin+12, 0010, "8. FATURAS/PAGAMENTO:",oFont09N)
opdc:Say(zLin+12, 0105, "Quando da compra de produtos, dever� ser emitida uma fatura separada para cada envio. Nenhuma fatura dever� ser emitida pela Vendedora antes do embarque das respectivas mercadorias e nenhum prazo de",oFont08)
opdc:Say(zLin+22, 0010, "pagamento come�ar� a correr antes do recebimento e aceita��o das mercadorias, e das respectivas faturas, em conformidade com esta ordem de compra e sem v�cios.",oFont08)

zLin += 0035
opdc:Box(zLin, 0000, zLin+50, 0800)
opdc:Say(zLin+12, 0010, "9. RESPONSABILIDADE PELA PROPRIEDADE:",oFont09N)
opdc:Say(zLin+12, 0170, "Salvo disposi��o em contr�rio nesta ordem de compra, a Vendedora, ao entregar, transportar, fabricar, adaptar, adquirir ou exercer a guarda de materiais, pe�as, ferramentas ou quaisquer",oFont08)
opdc:Say(zLin+22, 0010, "outras propriedades de titularidade da Compradora, ser� integralmente respons�vel por qualquer perda ou dano causado � Compradora e/ou terceiros. A Vendedora, de acordo com as disposi��es desta ordem de compra e, em qualquer caso",oFont08)
opdc:Say(zLin+32, 0010, "ap�s a sua extin��o, dever� devolver tal propriedade � Compradora nas condi��es em que foi recebida, exceto por desgaste natural ou na medida em que tal propriedade tenha sido incorporada a produtos ou consumida na presta��o dos",oFont08)
opdc:Say(zLin+42, 0010, "servi�os previstos sob esta ordem de compra.",oFont08)

zLin += 0055
opdc:Box(zLin, 0000, zLin+50, 0800)
opdc:Say(zLin+12, 0010, "10. INDENIZA��O:",oFont09N)
opdc:Say(zLin+12, 0075, "A Vendedora dever� indenizar, isentar de responsabilidade e defender a Compradora e quaisquer terceiros (incluindo, mas se limitar a, funcion�rios, vendedores, prepostos, clientes, seguradoras e usu�rios dos bens",oFont08)
opdc:Say(zLin+22, 0010, "e servi�os) de todas e quaisquer reivindica��es, assumindo eventuais danos diretos e indiretos, incluindo lucros cessantes, custas processuais e honor�rios advocat�cios, decorrentes direta ou indiretamente ou, ainda, em conex�o com",oFont08)
opdc:Say(zLin+32, 0010, "quaisquer bens e servi�os fornecidos sob esta ordem de compra. Esta indeniza��o ser� aplic�vel independentemente de a reclama��o ou dano decorrer de quebra contratual, viola��o legal, culpa ou dolo da Vendedora e ainda que haja",oFont08)
opdc:Say(zLin+42, 0010, "culpa concorrente da Compradora e/ou terceiros, hip�tese na qual a Vendedora responder� proporcionalmente � sua responsabilidade. Esta indeniza��o sobreviver� � entrega e aceita��o de bens ou servi�os sob esta ordem de compra.",oFont08)

zLin += 0055
opdc:Box(zLin, 0000, zLin+50, 0800)
opdc:Say(zLin+12, 0010, "11. SEGURO:",oFont09N)
opdc:Say(zLin+12, 0060, "A Vendedora dever� fornecer � Compradora ap�lices de seguro, contratadas junto a companhias de seguros de primeira linha e satisfat�rias para a Compradora, h�beis a comprovar os tipos e valores exigidos pela Compradora",oFont08)
opdc:Say(zLin+22, 0010, "antes do in�cio de qualquer trabalho nas instala��es da Compradora. A Compradora e suas controladoras, subsidi�rias e empresas afiliadas ter�o o direito de sub- rogar-se nos direitos da companhia de seguro e da Vendedora, a t�tulo de",oFont08)
opdc:Say(zLin+32, 0010, "benefici�ria. O seguro ser� mantido pelo per�odo especificado pela Compradora ou, se nenhum per�odo for especificado, enquanto o trabalho nas instala��es da Compradora estiver em andamento. Na ap�lice de seguro dever� constar",oFont08)
opdc:Say(zLin+42, 0010, "necessidade de a seguradora avisar a Compradora, na qualidade de benefici�ria da ap�lice, quanto a eventual cancelamento ou altera��o da ap�lice, com 30 (trinta) dias de anteced�ncia.",oFont08)

opdc:EndPage()
opdc:StartPage()
zFolha += 1
opdc:Say(0040, 0660, "Folha: "+AllTrim(STR(zFolha))+" de "+AllTrim(STR(zTotFol)),oFont12)
zLin := 0050

opdc:Box(zLin, 0000, zLin+50, 0800)
opdc:Say(zLin+12, 0010, "12. PROPRIEDADE INTELECTUAL:",oFont09N)
opdc:Say(zLin+12, 0130, "A Vendedora garante que todos os bens e servi�os fornecidos sob esta ordem de compra n�o infringir�o patentes, desenhos industriais, direitos autorais, segredos comerciais, nomes, marcas ou quaisquer",oFont08)
opdc:Say(zLin+22, 0010, "outros direitos de propriedade intelectual da pr�pria Compradora ou terceiros. A Vendedora dever�, �s suas pr�prias custas, indenizar, isentar de responsabilidade e defender a Compradora e quaisquer terceiros (incluindo, mas se limitar a,",oFont08)
opdc:Say(zLin+32, 0010, "funcion�rios, vendedores, prepostos, clientes, seguradoras e usu�rios dos bens e servi�os) de todas e quaisquer reivindica��es de terceiros versando acerca de viola��o a patentes, desenhos industriais, direitos autorais, segredos comerciais,",oFont08)
opdc:Say(zLin+42, 0010, "nomes, marcas ou quaisquer outros direitos de propriedade intelectual da pr�pria Compradora ou de terceiros, assumindo eventuais danos diretos e indiretos, incluindo lucros cessantes, custas processuais e honor�rios advocat�cios.",oFont08)

zLin += 0055
opdc:Box(zLin, 0000, zLin+30, 0800)
opdc:Say(zLin+12, 0010, "13. T�TULO E RISCO DE PERDA:",oFont09N)
opdc:Say(zLin+12, 0123, "A Vendedora garante a titularidade de todos os itens vendidos e assume o risco de eventuais perdas e danos que eventualmente venham a recair sobre referidos itens at� que sejam entregues � Compradora,",oFont08)
opdc:Say(zLin+22, 0010, "no ponto FOB especificado nesta ordem de compra. Ap�s a conclus�o da referida entrega, a titularidade passar� da Vendedora � Compradora. A transfer�ncia de titularidade n�o constituir� aceita��o dos itens pela Compradora.",oFont08)

zLin += 0035
opdc:Box(zLin, 0000, zLin+60, 0800)
opdc:Say(zLin+12, 0010, "14. CONFIDENCIALIDADE:",oFont09N)
opdc:Say(zLin+12, 0103, "A Vendedora manter� confidenciais todos os documentos e informa��es divulgadas pela Compradora, incluindo, mas sem se limitar a, projetos, processos, desenhos, especifica��es, relat�rios, dados e outras",oFont08)
opdc:Say(zLin+22, 0010, "informa��es t�cnicas ou comerciais, bem como as caracter�sticas de todas as pe�as, equipamentos, ferramentas, medidores, padr�es e outros itens fornecidos ou divulgados � Vendedora pela Compradora em conex�o com esta ordem de",oFont08)
opdc:Say(zLin+32, 0010, "compra. A menos que autorizado diversamente e por escrito pela Compradora, a Vendedora dever� utilizar tais documentos e informa��es, �nica e exclusivamente, na execu��o desta ordem de compra. Ap�s a conclus�o ou rescis�o desta",oFont08)
opdc:Say(zLin+42, 0010, "ordem de compra, a Vendedora dever� devolver todas essas informa��es e itens � Compradora ou adotar qualquer outra provid�ncia solicitada ou aprovada pela Compradora. Os termos e a exist�ncia desta ordem de compra, bem como",oFont08)
opdc:Say(zLin+52, 0010, "todos os dados e informa��es que forem compartilhadas pela Compradora, ser�o mantidos em sigilo pela Vendedora.",oFont08)

zLin += 0065
opdc:Box(zLin, 0000, zLin+20, 0800)
opdc:Say(zLin+12, 0010, "15. CONFORMIDADE LEGAL:",oFont09N)
opdc:Say(zLin+12, 0113, "A Vendedora garante que todos os bens e servi�os fornecidos sob esta ordem de compra cumprir�o com todas as normas, em �mbito internacional, federal, estadual e/ou municipal aplic�veis.",oFont08)

zLin += 0025
opdc:Box(zLin, 0000, zLin+120, 0800)
opdc:Say(zLin+12, 0010, "16. CANCELAMENTO DE PEDIDO:",oFont09N)
opdc:Say(zLin+12, 0128, "A Compradora pode cancelar integralmente ou parcialmente esta ordem de compra a qualquer momento, bastando notificar a Vendedora. Caso a Compradora opte por desistir imotivadamente desta ordem",oFont08)
opdc:Say(zLin+22, 0010, "de compra, referindo-se esta ao fornecimento de bens, sua responsabilidade ser� a menor entre: (a) caso n�o fixado expressamente na ordem de compra, o pre�o razo�vel pelas mat�rias-primas e componentes j� empregados,",oFont08)
opdc:Say(zLin+32, 0010, "trabalhos j� realizados e quaisquer unidades de bens j� acabados, desde que sejam devidamente disponibilizados; ou (b) caso fixado expressamente na ordem de compra, o pre�o aqui estabelecido para unidades de bens acabados e",oFont08)
opdc:Say(zLin+42, 0010, "disponibilizados ou servi�os, depois de aplicados quaisquer descontos a que a Compradora teria direito. Se qualquer taxa hor�ria ou outra taxa baseada no tempo para servi�os for especificada nesta ordem de compra, essa taxa ser� usada",oFont08)
opdc:Say(zLin+52, 0010, "para determinar o pre�o razo�vel da contrapresta��o a ser paga pela Compradora. Ap�s o recebimento de um aviso de cancelamento, a Vendedora dever�, a menos que indicado de outra forma, cessar o trabalho e seguir as instru��es da",oFont08)
opdc:Say(zLin+62, 0010, "Compradora quanto � interrup��o de trabalhos em andamento e eventual elimina��o de produtos j� acabados. O QUANTO PREVISTO ANTERIORMENTE ESTABELECE A RESPONSABILIDADE INTEGRAL DA COMPRADORA NO CASO",oFont08)
opdc:Say(zLin+72, 0010, "DE OPTAR PELO CANCELAMENTO DESTA ORDEM DE COMPRA, N�O SENDO DEVIDA QUALQUER INDENIZA��O. Al�m disso, a Compradora pode, mediante notifica��o � Vendedora, rescindir total ou parcialmente esta ordem de",oFont08)
opdc:Say(zLin+82, 0010, "compra em caso de suspens�o dos seus neg�cios, insolv�ncia, institui��o de fal�ncia, recupera��o judicial ou processo de liquida��o ou quaisquer cess�es dos cr�ditos pelo Vendedor em benef�cio de credores. Os direitos da Compradora",oFont08)
opdc:Say(zLin+92, 0010, "previstos nesta cl�usula n�o ser�o exclusivos e se somam a quaisquer outros direitos e recursos previstos por lei ou sob esta ordem de compra. N�o obstante o acima exposto, se a Compradora cancelar toda ou qualquer parte desta ordem",oFont08)
opdc:Say(zLin+102,0010, "de compra devido � viola��o pelo Vendedor de qualquer termo ou condi��o contida nesta ordem de compra, a Compradora n�o ser� respons�vel por quaisquer custos, perdas ou danos de qualquer tipo incorridos pela Vendedora antes ou como",oFont08)
opdc:Say(zLin+112,0010, "resultado de tal rescis�o.",oFont08)

zLin += 0125
opdc:Box(zLin, 0000, zLin+40, 0800)
opdc:Say(zLin+12, 0010, "17. RESPONSABILIDADES TRABALHISTAS:",oFont09N)
opdc:Say(zLin+12, 0160, "A Vendedora ser� exclusivamente respons�vel pelas obriga��es trabalhistas, previdenci�rias e fiscais relativas aos seus pr�prios empregados, comprometendo-se a defender a Compradora",oFont08)
opdc:Say(zLin+22, 0010, "diante de eventuais reclama��es, bem como indeniz�-la no caso de dispender qualquer valor na salvaguarda de seus direitos. Al�m disso, a Vendedora compromete-se a providenciar a imediata substitui��o de quaisquer de seus empregados",oFont08)
opdc:Say(zLin+32, 0010, "e/ou subcontratados, cuja conduta seja considerada inadequada pela Compradora, em tempo h�bil, a fim de que n�o haja impacto no cronograma acordado.",oFont08)

zLin += 0045
opdc:Box(zLin, 0000, zLin+40, 0800)
opdc:Say(zLin+12, 0010, "18. ANTICORRUP��O:",oFont09N)
opdc:Say(zLin+12, 0090, "As Partes dever�o, durante todo o prazo desta ordem e servi�o, cumprir a lei antissuborno, corrup��o e mat�rias correlatas (expressamente a Lei n� 12.846/13 � Lei Anticorrup��o Brasileira), bem como outras normas",oFont08)
opdc:Say(zLin+22, 0010, "aplic�veis � mat�ria. A parte infratora dever� indenizar a outra parte e mant�-la isenta da viola��o causada de quaisquer leis ou regulamentos anticorrup��o aplic�veis. A parte inocente reserva-se no ao direito de rescindir esta ordem de",oFont08)
opdc:Say(zLin+32, 0010, "compra em caso de qualquer viola��o comprovada destas regras anticorrup��o.",oFont08)

zLin += 0045
opdc:Box(zLin, 0000, zLin+30, 0800)
opdc:Say(zLin+12, 0010, "19. NULIDADES:",oFont09N)
opdc:Say(zLin+12, 0070, "A nulidade ou anula��o de qualquer disposi��o desta ordem de compra n�o afetar� as demais, que permanecer�o v�lidas e eficazes. As Partes negociar�o, de boa-f�, a substitui��o das disposi��es invalidadas por novas",oFont08)
opdc:Say(zLin+22, 0010, "cl�usulas que reflitam o mesmo objetivo daquelas consideradas inv�lidas.",oFont08)

zLin += 0035
opdc:Box(zLin, 0000, zLin+20, 0800)
opdc:Say(zLin+12, 0010, "20. REN�NCIA:",oFont09N)
opdc:Say(zLin+12, 0065, "O atraso ou absten��o do exerc�cio do direito, por qualquer das Partes, em exigir o cumprimento de qualquer obriga��o estabelecida nos termos desta ordem de compra n�o significar� ren�ncia ou nova��o deste.",oFont08)

zLin += 0025
opdc:Box(zLin, 0000, zLin+30, 0800)
opdc:Say(zLin+12, 0010, "21. AUTONOMIA DAS PARTES:",oFont09N)
opdc:Say(zLin+12, 0120, "Os termos desta ordem de compra n�o implicam na constitui��o de sociedade, joint venture, rela��o de parceria ou de representa��o comercial entre as partes, nem ainda v�nculo empregat�cio entre",oFont08)
opdc:Say(zLin+22, 0010, "os empregados, prepostos, contratados e/ou subcontratados da Vendedora e da Compradora, sendo cada uma, �nica, integral e exclusivamente respons�vel por seus atos e obriga��es.",oFont08)

zLin += 0035
opdc:Box(zLin, 0000, zLin+20, 0800)
opdc:Say(zLin+12, 0010, "22. CESS�O:",oFont09N)
opdc:Say(zLin+12, 0058, "Os direitos e obriga��es estabelecidas nesta ordem de compra n�o podem ser cedidos e/ou transferidos pela Vendedora a qualquer t�tulo.",oFont08)

zLin += 0025
opdc:Box(zLin, 0000, zLin+30, 0800)
opdc:Say(zLin+12, 0010, "23. AUTONOMIA:",oFont09N)
opdc:Say(zLin+12, 0072, "Esta ordem de compra constitui o acordo total existente entre as Partes em rela��o � mat�ria aqui versada e revoga e substitui todos os acordos, declara��es e entendimentos havidos anteriormente entre as Partes,",oFont08)
opdc:Say(zLin+22, 0010, "seja escrito ou verbal. A presente ordem de compra e seus aditamentos vinculam as Partes e seus respectivos sucessores.",oFont08)

opdc:EndPage()
opdc:StartPage()
zFolha += 1
opdc:Say(0040, 0660, "Folha: "+AllTrim(STR(zFolha))+" de "+AllTrim(STR(zTotFol)),oFont12)
zLin := 0050

opdc:Box(zLin, 0000, zLin+30, 0800)
opdc:Say(zLin+12, 0010, "24. TRABALHO INFANTO-JUVENIL:",oFont09N)
opdc:Say(zLin+12, 0133, "As Partes declaram que n�o utilizam m�o-de-obra infanto-juvenil em suas atividades, atuando em estrito cumprimento com o disposto no art. 7�, inc. XXXIII, da Constitui��o Federal e no Estatuto",oFont08)
opdc:Say(zLin+22, 0010, "da Crian�a e do Adolescente - ECA.",oFont08)

zLin += 0035
opdc:Box(zLin, 0000, zLin+50, 0800)
opdc:Say(zLin+12, 0010, "25. MEIO AMBIENTE:",oFont09N)
opdc:Say(zLin+12, 0085, "� dever das Partes preservar o meio ambiente, evitando quaisquer pr�ticas que causem danos ao meio ambiente ou que o coloquem em risco, cumprindo integralmente com todas as leis federais, estaduais e",oFont08)
opdc:Say(zLin+22, 0010, "municipais aplic�veis, incluindo, mas n�o se limitando a, Lei n� 6.938/1981, que institui a Pol�tica Nacional do Meio Ambiente, Lei n� 9.605/1.998, que consiste na Lei dos Crimes Ambientais, bem como a Lei n� 12.305/2010, que institui a",oFont08)
opdc:Say(zLin+32, 0010, "Pol�tica Nacional de Res�duos S�lidos. Caber� exclusivamente � Vendedora a responsabilidade de reparar eventuais preju�zos ou danos que causar, direta ou indiretamente, ao meio ambiente no decorrer da execu��o desta ordem e servi�os,",oFont08)
opdc:Say(zLin+42, 0010, "devendo arcar com indeniza��es da� oriundas.",oFont08)

zLin += 0035
opdc:Box(zLin, 0000, zLin+30, 0800)
opdc:Say(zLin+12, 0010, "26. REPRESENTA��O:",oFont09N)
opdc:Say(zLin+12, 0090, "As Partes declaram, sob as penas da lei, que os procuradores e/ou representantes legais abaixo subscritos encontram-se devidamente constitu�dos na forma dos seus respectivos atos constitutivos, com poderes",oFont08)
opdc:Say(zLin+22, 0010, "para assumir as obriga��es contra�das nesta ordem de servi�os.",oFont08)

zLin += 0035
opdc:Box(zLin, 0000, zLin+40, 0800)
opdc:Say(zLin+12, 0010, "27. IGUALDADE DE OPORTUNIDADES:",oFont09N)
opdc:Say(zLin+12, 0145, "As Partes devem implementar pol�ticas internas que pro�bam discrimina��o negativa de qualquer natureza, tais como, mas sem se limitar a, em fun��o de qualquer defici�ncia, ra�a, etnia, cor,",oFont08)
opdc:Say(zLin+22, 0010, "religi�o, sexo, nacionalidade ou naturalidade. Al�m disso, referidas pol�ticas devem promover a��es afirmativas para empregar e avan�ar no emprego de indiv�duos sem levar em conta ra�a, cor, religi�o, sexo, orienta��o sexual, identidade",oFont08)
opdc:Say(zLin+32, 0010, "de g�nero, origem nacional, status de veterano protegido ou defici�ncia.",oFont08)

zLin += 0045
opdc:Box(zLin, 0000, zLin+20, 0800)
opdc:Say(zLin+12, 0010, "28. LEI APLIC�VEL:",oFont09N)
opdc:Say(zLin+12, 0080, "Esta ordem ser� regida e interpretada de acordo com as leis da rep�blica Federativa do Brasil.",oFont08)

zLin += 0025
opdc:Box(zLin, 0000, zLin+20, 0800)
opdc:Say(zLin+12, 0010, "29. SOLU��O DE CONFLITOS:",oFont09N)
opdc:Say(zLin+12, 0115, "Qualquer disputa, controv�rsia ou reivindica��o decorrente ou relacionada a esta ordem ser� resolvida pelo foro da Comarca de S�o Paulo, Estado de S�o Paulo, com exclus�o de qualquer outro.",oFont08)

opdc:EndPage()

cFilePrint := zPathPDF+zPdf+".pdf"
If lExibe
	opdc:Preview()
Else
	File2Printer( cFilePrint, "PDF" )
	opdc:Preview()
	CpyT2S( cFilePrint, "\U6", .F. )
Endif	

Return

/*/
_____________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Funcao    � pdcCab  � Autor �  Fabrica ERPBR    � Data � 18/04/2023	  ���
��+----------+------------------------------------------------------------���
���Descricao � Impress�o do cabe�alho.									  ���
��+----------+------------------------------------------------------------���
���Uso       � Exclusivo INTRALOX										  ���
��+----------+------------------------------------------------------------���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function pdcCab(zFolha,zTotFol,lCabDet)

Local cStartPath := GetSrvProfString("Startpath","")
Local cLogoTp    := cStartPath + "logo_intraloxU6.bmp"

Local oFont08N := TFont():New("Arial",08,08,,.T.,,,,.T.,.F.)
Local oFont10  := TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
Local oFont10N := TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
Local oFont12  := TFont():New("Arial",12,12,,.F.,,,,.T.,.F.)
Local oFont16N := TFont():New("Arial",16,16,,.T.,,,,.T.,.F.)

opdc:SayBitmap(0025, 0000, cLogoTp, 0130, 0070)

opdc:Say(0060, 0325, "PEDIDO DE COMPRA:",oFont16N)
opdc:Say(0060, 0465, SC7->C7_NUM,oFont16N,,IIf(GetMv("MV_IMPXML"),CLR_HRED,CLR_BLACK))

opdc:Say(0045, 0660, "Folha: "+AllTrim(STR(zFolha))+" de "+AllTrim(STR(zTotFol)),oFont12)
opdc:Say(0060, 0660, "Emiss�o: "+DtoC(SC7->C7_EMISSAO),oFont12)
opdc:Say(0075, 0660, "Fonte: Protheus "+MesExtenso(SC7->C7_EMISSAO)+" "+Year2Str(SC7->C7_EMISSAO),oFont12)

opdc:Box(0090, 0000, 0170, 0800)
opdc:Line(0090, 0400, 0170, 0400)

opdc:Say(0100, 0010, "Solicitante",oFont08N)
opdc:Say(0115, 0010, SM0->M0_NOMECOM,oFont10)
opdc:Say(0130, 0010, "CNPJ: "+Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")+"  -  I.E: "+SM0->M0_INSC,oFont10)
opdc:Say(0145, 0010, AllTrim(SM0->M0_ENDENT)+" "+AllTrim(SM0->M0_BAIRCOB)+" - "+AllTrim(SM0->M0_CIDCOB)+"/"+AllTrim(SM0->M0_ESTCOB)+" - CEP: "+Transform(SM0->M0_CEPCOB,"@R 99999-999"),oFont10)
opdc:Say(0160, 0010, "TEL.: +55 19 2516-8900",oFont10)

opdc:Say(0100, 0405, "Fornecedor",oFont08N)
opdc:Say(0115, 0405, AllTrim(SA2->A2_COD)+" - "+AllTrim(SA2->A2_NOME),oFont10)
opdc:Say(0115, 0660, "CNPJ: "+Transform(SA2->A2_CGC,"@R 99.999.999/9999-99"),oFont10)
opdc:Say(0130, 0405, AllTrim(SA2->A2_END),oFont10)
opdc:Say(0130, 0660, "IE: "+Transform(SA2->A2_INSCR,"@R 999.999.999"),oFont10)
opdc:Say(0145, 0405, AllTrim(SA2->A2_BAIRRO)+" - "+AllTrim(SA2->A2_MUN)+"/"+AllTrim(SA2->A2_EST)+" - CEP: "+Transform(SA2->A2_CEP,"@R 99999-999"),oFont10)
opdc:Say(0160, 0405, "TEL.: "+SA2->A2_TEL,oFont10)

If lCabDet
	opdc:Say(0185, 0000, "Item",oFont10N)
	opdc:Say(0180, 0030, "C�digo",oFont10N)
	opdc:Say(0192, 0030, "N.C.M.",oFont10N)
	opdc:Say(0185, 0140, "Qtde",oFont10N)
	opdc:Say(0185, 0190, "Unidade",oFont10N)
	opdc:Say(0180, 0240, "Descri��o",oFont10N)
	opdc:Say(0192, 0240, "Observa��es",oFont10N)
	opdc:Say(0185, 0445, "Vl.Unit.",oFont10N)
	opdc:Say(0185, 0505, "Vl.Total",oFont10N)
	opdc:Say(0185, 0570, "%.ICMS",oFont10N)
	opdc:Say(0185, 0640, "%.IPI",oFont10N)
	opdc:Say(0185, 0700, "Arm.",oFont10N)
	opdc:Say(0185, 0750, "Dt.Entrega",oFont10N)
	opdc:Line(0195, 0000, 0195, 0800)
Endif

Return

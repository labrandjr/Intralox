#include "protheus.ch"
#include "tbiconn.ch"
#include "colors.ch"
#include "rptdef.ch"
#include "FWPrintSetup.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ PDFPEDC   ¦ Autor ¦  Fabrica ERPBR    ¦ Data ¦ 18/04/2023  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Pedido de Compra modelo Pdf.								  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo INTRALOX										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
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
Local lModDes  := .T. // Modelo de impressão que exibe o preço unitário com desconto
Local zTpFret  := ""
Local pdc, _pdc
Private opdc

If !(FWCodEmp() $("99,U6"))
	MsgAlert("Empresa não autorizada: "+FWCodEmp())
	Return
Endif

If Len(aPedido) == 0
	MsgAlert("Sem dados para geração do Pdf.")
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
zPdf := StrTran(zPdf,"º","")
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
	zDsFrete := "Não Informado"
ElseIf zTpFret == "C"
	zDsFrete := "CIF"
ElseIf zTpFret == "F"
	zDsFrete := "FOB"
ElseIf zTpFret == "T"
	zDsFrete := "Terceiros"
ElseIf zTpFret == "R"
	zDsFrete := "Remetente"
ElseIf zTpFret == "D"
	zDsFrete := "Destinatário"
ElseIf zTpFret == "S"
	zDsFrete := "Sem Frete"
Endif

opdc:Say(zLin, 0000, "Valores expressos em: "+zMoedPc + Space(30) + "Tx.Conversão: "+Transform(zTaxaPc,"@E 9.9999") + Space(30) + "Prazo programado p/ entrega: "+DtoC(zEntreg) + Space(30) + "Cond.Pagamento: "+AllTrim(SE4->E4_DESCRI) + Space(30) + "Tp.Frete: "+zDsFrete,oFont10)
zLin += 15
opdc:Say(zLin, 0000, "Endereço de entrega: "+zEndEnt,oFont10)
zLin += 15
opdc:Say(zLin, 0000, "Endereço de cobrança: "+zEndCob,oFont10)
zLin += 15
opdc:Say(zLin, 0000, "Situação do Pedido: "+IIf(SC7->C7_CONAPRO=="L","APROVADO","EM APROVAÇÃO"),oFont10N)
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
opdc:Say(zLin+12, 0220, "TERMOS E CONDIÇÕES DA ORDEM DE COMPRA DA INTRALOX DO BRASIL LTDA. (COMPRADORA)",oFont10N)

zLin += 0025
opdc:Box(zLin, 0000, zLin+50, 0800)
opdc:Say(zLin+12, 0010, "1. ACEITAÇÃO:",oFont09N)
opdc:Say(zLin+12, 0065, "Salvo indicação por escrito em contrário, o pagamento dos valores devidos pela Compradora à Vendedora está condicionado à entrega satisfatória dos serviços e/ou produtos em conformidade com o cronograma previsto nesta",oFont08)
opdc:Say(zLin+22, 0010, "ordem de compra. Esta ordem de compra será regida única e exclusivamente pelos termos e condições especificados em seu quadro resumo (página 1), neste Termos e em seus anexos, não estando autorizada qualquer alteração, adição e/ou",oFont08)
opdc:Say(zLin+32, 0010, "exclusão das cláusulas deste Termo, exceto mediante a assinatura, por ambas as Partes, de termo aditivo. No caso de conflito entre o quadro resumo, estes Termos e seus anexos, prevalecerá o quanto previsto nestes Termos, exceto caso",oFont08)
opdc:Say(zLin+42, 0010, "nele indicado diversamente por escrito.",oFont08)

zLin += 0055
opdc:Box(zLin, 0000, zLin+40, 0800)
opdc:Say(zLin+12, 0010, "2. EMBALAGEM E ENVIO:",oFont09N)
opdc:Say(zLin+12, 0100, "Todos os produtos previstos nesta ordem de compra deverão ser devidamente preparados, embalados e acondicionados para que sejam entregues à Compradora, a fim de garantir as menores taxas de transporte",oFont08)
opdc:Say(zLin+22, 0010, "e cumprir com as leis aplicáveis e os regulamentos internos da transportadora. Nenhum custo adicional com embalagem, acondicionamento, gradeamento ou transporte será suportado pela Compradora, a menos que assim seja expressamente",oFont08)
opdc:Say(zLin+32, 0010, "indicado nesta ordem de compra. Todas as remessas de produtos a serem enviadas à Compradora em um mesmo dia e por uma mesma rota deverão ser consolidadas em um só envio.",oFont08)

zLin += 0045
opdc:Box(zLin, 0000, zLin+50, 0800)
opdc:Say(zLin+12, 0010, "3. ENVIO OU ENTREGA:",oFont09N)
opdc:Say(zLin+12, 0095, "O cumprimento dos prazos acordados entre as Partes é fundamental para o adimplemento desta ordem de compra pela Vendedora. Assim, o envio, entrega e execução dos serviços deverão respeitar o cronograma",oFont08)
opdc:Say(zLin+22, 0010, "e as quantidades exatas previstas na ordem de compra. Se a Vendedora não cumprir (ou apresentar indícios de que não cumprirá) o cronograma fixado entre as Partes, a Vendedora deverá, mediante solicitação da Compradora, e sem prejuízo",oFont08)
opdc:Say(zLin+32, 0010, "de quaisquer outros direitos ou remédios previstos neste Termo e/ou garantidos por lei, utilizar o tipo de envio prioritário hábil a cumprir referido cronograma ou minimizar ao máximo o seu atraso. A diferença entre o custo do envio",oFont08)
opdc:Say(zLin+42, 0010, "prioritário utilizado e o tipo de envio previsto no quadro resumo será suportado integralmente pela Vendedora.",oFont08)

zLin += 0055
opdc:Box(zLin, 0000, zLin+30, 0800)
opdc:Say(zLin+12, 0010, "4. INSPEÇÃO:",oFont09N)
opdc:Say(zLin+12, 0060, "Todos os itens estão sujeitos à inspeção final e aceitação, quando do seu recebimento pela Compradora, independentemente de qualquer pagamento ou inspeção prévia. A aceitação de quaisquer itens pela Compradora não",oFont08)
opdc:Say(zLin+22, 0010, "alterará as obrigações da Vendedora ou os direitos da Compradora e de seus clientes, previstos na cláusula de 6. GARANTIA ou em qualquer outra disposição desta ordem de compra.",oFont08)

zLin += 0035
opdc:Box(zLin, 0000, zLin+40, 0800)
opdc:Say(zLin+12, 0010, "5. REJEIÇÃO:",oFont09N)
opdc:Say(zLin+12, 0060, "A Compradora notificará a Vendedora se quaisquer itens entregues por força desta ordem de compra forem rejeitados, a Compradora poderá, a seu exclusivo critério, solicitar à Vendedora, sua: i) devolução, mediante o",oFont08)
opdc:Say(zLin+22, 0010, "reembolso proporcional do valor; ii) substituição; ou c) correção. Em qualquer dos casos, a Vendedora suportará integralmente os custos envolvidos, sendo que nenhuma das alternativas será adotada automaticamente pela Vendedora,",oFont08)
opdc:Say(zLin+32, 0010, "exceto mediante a aprovação prévia e por escrito da Compradora.",oFont08)

zLin += 0045
opdc:Box(zLin, 0000, zLin+40, 0800)
opdc:Say(zLin+12, 0010, "6. GARANTIA:",oFont09N)
opdc:Say(zLin+12, 0060, "A Vendedora garante que todos os bens aqui entregues serão comercializáveis, adequados à sua finalidade específica e livres de defeitos, ocultos ou aparentes. A Vendedora garante que todos os serviços serão executados",oFont08)
opdc:Say(zLin+22, 0010, "com a melhor técnica e livres de erros. As garantias sob a responsabilidade da Vendedora poderão ser reivindicadas pela Compradora e/ou seus clientes, sem quaisquer limitações ou exclusão de garantias contratuais ou legais.",oFont08)
opdc:Say(zLin+32, 0010, "A Vendedora garante que os itens fornecidos estarão em conformidade com as especificações, desenhos e descrições listados, bem como com a(s) amostra(s) fornecida(s) pela Vendedora, se houver.",oFont08)

zLin += 0045
opdc:Box(zLin, 0000, zLin+40, 0800)
opdc:Say(zLin+12, 0010, "7. ALTERAÇÕES:",oFont09N)
opdc:Say(zLin+12, 0070, "A Compradora poderá fazer alterações na especificação dos serviços a serem executados ou em bens a serem fabricados a seu pedido, negociando, as Partes, de boa-fé, eventuais aumentos ou reduções nos preços em",oFont08)
opdc:Say(zLin+22, 0010, "razão das alterações. Por outro lado, nenhuma alteração precisará ser aceita ou pagamento adicional realizado pela Compradora em decorrência de alterações unilaterais efetuadas por parte da Vendedora, sendo necessário, que referidas",oFont08)
opdc:Say(zLin+32, 0010, "alterações sejam submetidas à apreciação e aprovação prévia e por escrito da Compradora.",oFont08)

zLin += 0045
opdc:Box(zLin, 0000, zLin+30, 0800)
opdc:Say(zLin+12, 0010, "8. FATURAS/PAGAMENTO:",oFont09N)
opdc:Say(zLin+12, 0105, "Quando da compra de produtos, deverá ser emitida uma fatura separada para cada envio. Nenhuma fatura deverá ser emitida pela Vendedora antes do embarque das respectivas mercadorias e nenhum prazo de",oFont08)
opdc:Say(zLin+22, 0010, "pagamento começará a correr antes do recebimento e aceitação das mercadorias, e das respectivas faturas, em conformidade com esta ordem de compra e sem vícios.",oFont08)

zLin += 0035
opdc:Box(zLin, 0000, zLin+50, 0800)
opdc:Say(zLin+12, 0010, "9. RESPONSABILIDADE PELA PROPRIEDADE:",oFont09N)
opdc:Say(zLin+12, 0170, "Salvo disposição em contrário nesta ordem de compra, a Vendedora, ao entregar, transportar, fabricar, adaptar, adquirir ou exercer a guarda de materiais, peças, ferramentas ou quaisquer",oFont08)
opdc:Say(zLin+22, 0010, "outras propriedades de titularidade da Compradora, será integralmente responsável por qualquer perda ou dano causado à Compradora e/ou terceiros. A Vendedora, de acordo com as disposições desta ordem de compra e, em qualquer caso",oFont08)
opdc:Say(zLin+32, 0010, "após a sua extinção, deverá devolver tal propriedade à Compradora nas condições em que foi recebida, exceto por desgaste natural ou na medida em que tal propriedade tenha sido incorporada a produtos ou consumida na prestação dos",oFont08)
opdc:Say(zLin+42, 0010, "serviços previstos sob esta ordem de compra.",oFont08)

zLin += 0055
opdc:Box(zLin, 0000, zLin+50, 0800)
opdc:Say(zLin+12, 0010, "10. INDENIZAÇÃO:",oFont09N)
opdc:Say(zLin+12, 0075, "A Vendedora deverá indenizar, isentar de responsabilidade e defender a Compradora e quaisquer terceiros (incluindo, mas se limitar a, funcionários, vendedores, prepostos, clientes, seguradoras e usuários dos bens",oFont08)
opdc:Say(zLin+22, 0010, "e serviços) de todas e quaisquer reivindicações, assumindo eventuais danos diretos e indiretos, incluindo lucros cessantes, custas processuais e honorários advocatícios, decorrentes direta ou indiretamente ou, ainda, em conexão com",oFont08)
opdc:Say(zLin+32, 0010, "quaisquer bens e serviços fornecidos sob esta ordem de compra. Esta indenização será aplicável independentemente de a reclamação ou dano decorrer de quebra contratual, violação legal, culpa ou dolo da Vendedora e ainda que haja",oFont08)
opdc:Say(zLin+42, 0010, "culpa concorrente da Compradora e/ou terceiros, hipótese na qual a Vendedora responderá proporcionalmente à sua responsabilidade. Esta indenização sobreviverá à entrega e aceitação de bens ou serviços sob esta ordem de compra.",oFont08)

zLin += 0055
opdc:Box(zLin, 0000, zLin+50, 0800)
opdc:Say(zLin+12, 0010, "11. SEGURO:",oFont09N)
opdc:Say(zLin+12, 0060, "A Vendedora deverá fornecer à Compradora apólices de seguro, contratadas junto a companhias de seguros de primeira linha e satisfatórias para a Compradora, hábeis a comprovar os tipos e valores exigidos pela Compradora",oFont08)
opdc:Say(zLin+22, 0010, "antes do início de qualquer trabalho nas instalações da Compradora. A Compradora e suas controladoras, subsidiárias e empresas afiliadas terão o direito de sub- rogar-se nos direitos da companhia de seguro e da Vendedora, a título de",oFont08)
opdc:Say(zLin+32, 0010, "beneficiária. O seguro será mantido pelo período especificado pela Compradora ou, se nenhum período for especificado, enquanto o trabalho nas instalações da Compradora estiver em andamento. Na apólice de seguro deverá constar",oFont08)
opdc:Say(zLin+42, 0010, "necessidade de a seguradora avisar a Compradora, na qualidade de beneficiária da apólice, quanto a eventual cancelamento ou alteração da apólice, com 30 (trinta) dias de antecedência.",oFont08)

opdc:EndPage()
opdc:StartPage()
zFolha += 1
opdc:Say(0040, 0660, "Folha: "+AllTrim(STR(zFolha))+" de "+AllTrim(STR(zTotFol)),oFont12)
zLin := 0050

opdc:Box(zLin, 0000, zLin+50, 0800)
opdc:Say(zLin+12, 0010, "12. PROPRIEDADE INTELECTUAL:",oFont09N)
opdc:Say(zLin+12, 0130, "A Vendedora garante que todos os bens e serviços fornecidos sob esta ordem de compra não infringirão patentes, desenhos industriais, direitos autorais, segredos comerciais, nomes, marcas ou quaisquer",oFont08)
opdc:Say(zLin+22, 0010, "outros direitos de propriedade intelectual da própria Compradora ou terceiros. A Vendedora deverá, às suas próprias custas, indenizar, isentar de responsabilidade e defender a Compradora e quaisquer terceiros (incluindo, mas se limitar a,",oFont08)
opdc:Say(zLin+32, 0010, "funcionários, vendedores, prepostos, clientes, seguradoras e usuários dos bens e serviços) de todas e quaisquer reivindicações de terceiros versando acerca de violação a patentes, desenhos industriais, direitos autorais, segredos comerciais,",oFont08)
opdc:Say(zLin+42, 0010, "nomes, marcas ou quaisquer outros direitos de propriedade intelectual da própria Compradora ou de terceiros, assumindo eventuais danos diretos e indiretos, incluindo lucros cessantes, custas processuais e honorários advocatícios.",oFont08)

zLin += 0055
opdc:Box(zLin, 0000, zLin+30, 0800)
opdc:Say(zLin+12, 0010, "13. TÍTULO E RISCO DE PERDA:",oFont09N)
opdc:Say(zLin+12, 0123, "A Vendedora garante a titularidade de todos os itens vendidos e assume o risco de eventuais perdas e danos que eventualmente venham a recair sobre referidos itens até que sejam entregues à Compradora,",oFont08)
opdc:Say(zLin+22, 0010, "no ponto FOB especificado nesta ordem de compra. Após a conclusão da referida entrega, a titularidade passará da Vendedora à Compradora. A transferência de titularidade não constituirá aceitação dos itens pela Compradora.",oFont08)

zLin += 0035
opdc:Box(zLin, 0000, zLin+60, 0800)
opdc:Say(zLin+12, 0010, "14. CONFIDENCIALIDADE:",oFont09N)
opdc:Say(zLin+12, 0103, "A Vendedora manterá confidenciais todos os documentos e informações divulgadas pela Compradora, incluindo, mas sem se limitar a, projetos, processos, desenhos, especificações, relatórios, dados e outras",oFont08)
opdc:Say(zLin+22, 0010, "informações técnicas ou comerciais, bem como as características de todas as peças, equipamentos, ferramentas, medidores, padrões e outros itens fornecidos ou divulgados à Vendedora pela Compradora em conexão com esta ordem de",oFont08)
opdc:Say(zLin+32, 0010, "compra. A menos que autorizado diversamente e por escrito pela Compradora, a Vendedora deverá utilizar tais documentos e informações, única e exclusivamente, na execução desta ordem de compra. Após a conclusão ou rescisão desta",oFont08)
opdc:Say(zLin+42, 0010, "ordem de compra, a Vendedora deverá devolver todas essas informações e itens à Compradora ou adotar qualquer outra providência solicitada ou aprovada pela Compradora. Os termos e a existência desta ordem de compra, bem como",oFont08)
opdc:Say(zLin+52, 0010, "todos os dados e informações que forem compartilhadas pela Compradora, serão mantidos em sigilo pela Vendedora.",oFont08)

zLin += 0065
opdc:Box(zLin, 0000, zLin+20, 0800)
opdc:Say(zLin+12, 0010, "15. CONFORMIDADE LEGAL:",oFont09N)
opdc:Say(zLin+12, 0113, "A Vendedora garante que todos os bens e serviços fornecidos sob esta ordem de compra cumprirão com todas as normas, em âmbito internacional, federal, estadual e/ou municipal aplicáveis.",oFont08)

zLin += 0025
opdc:Box(zLin, 0000, zLin+120, 0800)
opdc:Say(zLin+12, 0010, "16. CANCELAMENTO DE PEDIDO:",oFont09N)
opdc:Say(zLin+12, 0128, "A Compradora pode cancelar integralmente ou parcialmente esta ordem de compra a qualquer momento, bastando notificar a Vendedora. Caso a Compradora opte por desistir imotivadamente desta ordem",oFont08)
opdc:Say(zLin+22, 0010, "de compra, referindo-se esta ao fornecimento de bens, sua responsabilidade será a menor entre: (a) caso não fixado expressamente na ordem de compra, o preço razoável pelas matérias-primas e componentes já empregados,",oFont08)
opdc:Say(zLin+32, 0010, "trabalhos já realizados e quaisquer unidades de bens já acabados, desde que sejam devidamente disponibilizados; ou (b) caso fixado expressamente na ordem de compra, o preço aqui estabelecido para unidades de bens acabados e",oFont08)
opdc:Say(zLin+42, 0010, "disponibilizados ou serviços, depois de aplicados quaisquer descontos a que a Compradora teria direito. Se qualquer taxa horária ou outra taxa baseada no tempo para serviços for especificada nesta ordem de compra, essa taxa será usada",oFont08)
opdc:Say(zLin+52, 0010, "para determinar o preço razoável da contraprestação a ser paga pela Compradora. Após o recebimento de um aviso de cancelamento, a Vendedora deverá, a menos que indicado de outra forma, cessar o trabalho e seguir as instruções da",oFont08)
opdc:Say(zLin+62, 0010, "Compradora quanto à interrupção de trabalhos em andamento e eventual eliminação de produtos já acabados. O QUANTO PREVISTO ANTERIORMENTE ESTABELECE A RESPONSABILIDADE INTEGRAL DA COMPRADORA NO CASO",oFont08)
opdc:Say(zLin+72, 0010, "DE OPTAR PELO CANCELAMENTO DESTA ORDEM DE COMPRA, NÃO SENDO DEVIDA QUALQUER INDENIZAÇÃO. Além disso, a Compradora pode, mediante notificação à Vendedora, rescindir total ou parcialmente esta ordem de",oFont08)
opdc:Say(zLin+82, 0010, "compra em caso de suspensão dos seus negócios, insolvência, instituição de falência, recuperação judicial ou processo de liquidação ou quaisquer cessões dos créditos pelo Vendedor em benefício de credores. Os direitos da Compradora",oFont08)
opdc:Say(zLin+92, 0010, "previstos nesta cláusula não serão exclusivos e se somam a quaisquer outros direitos e recursos previstos por lei ou sob esta ordem de compra. Não obstante o acima exposto, se a Compradora cancelar toda ou qualquer parte desta ordem",oFont08)
opdc:Say(zLin+102,0010, "de compra devido à violação pelo Vendedor de qualquer termo ou condição contida nesta ordem de compra, a Compradora não será responsável por quaisquer custos, perdas ou danos de qualquer tipo incorridos pela Vendedora antes ou como",oFont08)
opdc:Say(zLin+112,0010, "resultado de tal rescisão.",oFont08)

zLin += 0125
opdc:Box(zLin, 0000, zLin+40, 0800)
opdc:Say(zLin+12, 0010, "17. RESPONSABILIDADES TRABALHISTAS:",oFont09N)
opdc:Say(zLin+12, 0160, "A Vendedora será exclusivamente responsável pelas obrigações trabalhistas, previdenciárias e fiscais relativas aos seus próprios empregados, comprometendo-se a defender a Compradora",oFont08)
opdc:Say(zLin+22, 0010, "diante de eventuais reclamações, bem como indenizá-la no caso de dispender qualquer valor na salvaguarda de seus direitos. Além disso, a Vendedora compromete-se a providenciar a imediata substituição de quaisquer de seus empregados",oFont08)
opdc:Say(zLin+32, 0010, "e/ou subcontratados, cuja conduta seja considerada inadequada pela Compradora, em tempo hábil, a fim de que não haja impacto no cronograma acordado.",oFont08)

zLin += 0045
opdc:Box(zLin, 0000, zLin+40, 0800)
opdc:Say(zLin+12, 0010, "18. ANTICORRUPÇÃO:",oFont09N)
opdc:Say(zLin+12, 0090, "As Partes deverão, durante todo o prazo desta ordem e serviço, cumprir a lei antissuborno, corrupção e matérias correlatas (expressamente a Lei nº 12.846/13 – Lei Anticorrupção Brasileira), bem como outras normas",oFont08)
opdc:Say(zLin+22, 0010, "aplicáveis à matéria. A parte infratora deverá indenizar a outra parte e mantê-la isenta da violação causada de quaisquer leis ou regulamentos anticorrupção aplicáveis. A parte inocente reserva-se no ao direito de rescindir esta ordem de",oFont08)
opdc:Say(zLin+32, 0010, "compra em caso de qualquer violação comprovada destas regras anticorrupção.",oFont08)

zLin += 0045
opdc:Box(zLin, 0000, zLin+30, 0800)
opdc:Say(zLin+12, 0010, "19. NULIDADES:",oFont09N)
opdc:Say(zLin+12, 0070, "A nulidade ou anulação de qualquer disposição desta ordem de compra não afetará as demais, que permanecerão válidas e eficazes. As Partes negociarão, de boa-fé, a substituição das disposições invalidadas por novas",oFont08)
opdc:Say(zLin+22, 0010, "cláusulas que reflitam o mesmo objetivo daquelas consideradas inválidas.",oFont08)

zLin += 0035
opdc:Box(zLin, 0000, zLin+20, 0800)
opdc:Say(zLin+12, 0010, "20. RENÚNCIA:",oFont09N)
opdc:Say(zLin+12, 0065, "O atraso ou abstenção do exercício do direito, por qualquer das Partes, em exigir o cumprimento de qualquer obrigação estabelecida nos termos desta ordem de compra não significará renúncia ou novação deste.",oFont08)

zLin += 0025
opdc:Box(zLin, 0000, zLin+30, 0800)
opdc:Say(zLin+12, 0010, "21. AUTONOMIA DAS PARTES:",oFont09N)
opdc:Say(zLin+12, 0120, "Os termos desta ordem de compra não implicam na constituição de sociedade, joint venture, relação de parceria ou de representação comercial entre as partes, nem ainda vínculo empregatício entre",oFont08)
opdc:Say(zLin+22, 0010, "os empregados, prepostos, contratados e/ou subcontratados da Vendedora e da Compradora, sendo cada uma, única, integral e exclusivamente responsável por seus atos e obrigações.",oFont08)

zLin += 0035
opdc:Box(zLin, 0000, zLin+20, 0800)
opdc:Say(zLin+12, 0010, "22. CESSÃO:",oFont09N)
opdc:Say(zLin+12, 0058, "Os direitos e obrigações estabelecidas nesta ordem de compra não podem ser cedidos e/ou transferidos pela Vendedora a qualquer título.",oFont08)

zLin += 0025
opdc:Box(zLin, 0000, zLin+30, 0800)
opdc:Say(zLin+12, 0010, "23. AUTONOMIA:",oFont09N)
opdc:Say(zLin+12, 0072, "Esta ordem de compra constitui o acordo total existente entre as Partes em relação à matéria aqui versada e revoga e substitui todos os acordos, declarações e entendimentos havidos anteriormente entre as Partes,",oFont08)
opdc:Say(zLin+22, 0010, "seja escrito ou verbal. A presente ordem de compra e seus aditamentos vinculam as Partes e seus respectivos sucessores.",oFont08)

opdc:EndPage()
opdc:StartPage()
zFolha += 1
opdc:Say(0040, 0660, "Folha: "+AllTrim(STR(zFolha))+" de "+AllTrim(STR(zTotFol)),oFont12)
zLin := 0050

opdc:Box(zLin, 0000, zLin+30, 0800)
opdc:Say(zLin+12, 0010, "24. TRABALHO INFANTO-JUVENIL:",oFont09N)
opdc:Say(zLin+12, 0133, "As Partes declaram que não utilizam mão-de-obra infanto-juvenil em suas atividades, atuando em estrito cumprimento com o disposto no art. 7º, inc. XXXIII, da Constituição Federal e no Estatuto",oFont08)
opdc:Say(zLin+22, 0010, "da Criança e do Adolescente - ECA.",oFont08)

zLin += 0035
opdc:Box(zLin, 0000, zLin+50, 0800)
opdc:Say(zLin+12, 0010, "25. MEIO AMBIENTE:",oFont09N)
opdc:Say(zLin+12, 0085, "É dever das Partes preservar o meio ambiente, evitando quaisquer práticas que causem danos ao meio ambiente ou que o coloquem em risco, cumprindo integralmente com todas as leis federais, estaduais e",oFont08)
opdc:Say(zLin+22, 0010, "municipais aplicáveis, incluindo, mas não se limitando a, Lei nº 6.938/1981, que institui a Política Nacional do Meio Ambiente, Lei nº 9.605/1.998, que consiste na Lei dos Crimes Ambientais, bem como a Lei nº 12.305/2010, que institui a",oFont08)
opdc:Say(zLin+32, 0010, "Política Nacional de Resíduos Sólidos. Caberá exclusivamente à Vendedora a responsabilidade de reparar eventuais prejuízos ou danos que causar, direta ou indiretamente, ao meio ambiente no decorrer da execução desta ordem e serviços,",oFont08)
opdc:Say(zLin+42, 0010, "devendo arcar com indenizações daí oriundas.",oFont08)

zLin += 0035
opdc:Box(zLin, 0000, zLin+30, 0800)
opdc:Say(zLin+12, 0010, "26. REPRESENTAÇÃO:",oFont09N)
opdc:Say(zLin+12, 0090, "As Partes declaram, sob as penas da lei, que os procuradores e/ou representantes legais abaixo subscritos encontram-se devidamente constituídos na forma dos seus respectivos atos constitutivos, com poderes",oFont08)
opdc:Say(zLin+22, 0010, "para assumir as obrigações contraídas nesta ordem de serviços.",oFont08)

zLin += 0035
opdc:Box(zLin, 0000, zLin+40, 0800)
opdc:Say(zLin+12, 0010, "27. IGUALDADE DE OPORTUNIDADES:",oFont09N)
opdc:Say(zLin+12, 0145, "As Partes devem implementar políticas internas que proíbam discriminação negativa de qualquer natureza, tais como, mas sem se limitar a, em função de qualquer deficiência, raça, etnia, cor,",oFont08)
opdc:Say(zLin+22, 0010, "religião, sexo, nacionalidade ou naturalidade. Além disso, referidas políticas devem promover ações afirmativas para empregar e avançar no emprego de indivíduos sem levar em conta raça, cor, religião, sexo, orientação sexual, identidade",oFont08)
opdc:Say(zLin+32, 0010, "de gênero, origem nacional, status de veterano protegido ou deficiência.",oFont08)

zLin += 0045
opdc:Box(zLin, 0000, zLin+20, 0800)
opdc:Say(zLin+12, 0010, "28. LEI APLICÁVEL:",oFont09N)
opdc:Say(zLin+12, 0080, "Esta ordem será regida e interpretada de acordo com as leis da república Federativa do Brasil.",oFont08)

zLin += 0025
opdc:Box(zLin, 0000, zLin+20, 0800)
opdc:Say(zLin+12, 0010, "29. SOLUÇÃO DE CONFLITOS:",oFont09N)
opdc:Say(zLin+12, 0115, "Qualquer disputa, controvérsia ou reivindicação decorrente ou relacionada a esta ordem será resolvida pelo foro da Comarca de São Paulo, Estado de São Paulo, com exclusão de qualquer outro.",oFont08)

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
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ pdcCab  ¦ Autor ¦  Fabrica ERPBR    ¦ Data ¦ 18/04/2023	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Impressão do cabeçalho.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo INTRALOX										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
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
opdc:Say(0060, 0660, "Emissão: "+DtoC(SC7->C7_EMISSAO),oFont12)
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
	opdc:Say(0180, 0030, "Código",oFont10N)
	opdc:Say(0192, 0030, "N.C.M.",oFont10N)
	opdc:Say(0185, 0140, "Qtde",oFont10N)
	opdc:Say(0185, 0190, "Unidade",oFont10N)
	opdc:Say(0180, 0240, "Descrição",oFont10N)
	opdc:Say(0192, 0240, "Observações",oFont10N)
	opdc:Say(0185, 0445, "Vl.Unit.",oFont10N)
	opdc:Say(0185, 0505, "Vl.Total",oFont10N)
	opdc:Say(0185, 0570, "%.ICMS",oFont10N)
	opdc:Say(0185, 0640, "%.IPI",oFont10N)
	opdc:Say(0185, 0700, "Arm.",oFont10N)
	opdc:Say(0185, 0750, "Dt.Entrega",oFont10N)
	opdc:Line(0195, 0000, 0195, 0800)
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ ITLXRPT   ¦ Autor ¦  Fabrica ERPBR    ¦ Data ¦ 19/08/2025  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Boletim de Medição em Pdf.								  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo INTRALOX										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

#include "protheus.ch"
#include "tbiconn.ch"
#include "colors.ch"
#include "rptdef.ch"
#include "FWPrintSetup.ch"

// ---------------------------------------------------------------------------
// Layout constants
// ---------------------------------------------------------------------------
#Define PDF_RIGHT   570
#Define PDF_BOTTOM  835
#Define PGNUM_Y      50
#Define PGNUM_X     500
#Define PL_C1         5
#Define PL_C2        75
#Define PL_C3       250
#Define PL_C4       320
#Define PL_C5       410
#Define PL_C6       450
#Define PL_C7       490
#Define PL_C8       530
#Define PL_ROW_H     40
#Define CL_ROW_H     42

// ===========================================================================
//  MAIN ENTRY POINT
// ===========================================================================
User Function ITLXRPT(aOrdemP, cPathPDF, lExibe)

Local zPdf       := AllTrim(aOrdemP[1][2])+"-"+DtoS(Date())+"-"+StrTran(Time(),":","")
Local zPathPDF   := AllTrim(cPathPdf)+"\"
Local zTotFol    := 1
Local cStartPath := GetSrvProfString("Startpath","")
Private cLogoTp  := cStartPath + "logo_intraloxU6.bmp"

zPdf := StrTran(zPdf,".","")
zPdf := StrTran(zPdf,",","")
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

Private opdc   := Nil
Private oF07   := TFont():New( "Arial",  7,  7,, .F.,,,,  .T., .F. )
Private oF07N  := TFont():New( "Arial",  7,  7,, .T.,,,,  .T., .F. )
Private oF08   := TFont():New( "Arial",  8,  8,, .F.,,,,  .T., .F. )
Private oF09   := TFont():New( "Arial",  9,  9,, .F.,,,,  .T., .F. )
Private oF09N  := TFont():New( "Arial",  9,  9,, .T.,,,,  .T., .F. )
Private oF10   := TFont():New( "Arial", 10, 10,, .F.,,,,  .T., .F. )
Private oF10N  := TFont():New( "Arial", 10, 10,, .T.,,,,  .T., .F. )
Private oF12N  := TFont():New( "Arial", 12, 12,, .T.,,,,  .T., .F. )
Private oF14N  := TFont():New( "Arial", 14, 14,, .T.,,,,  .T., .F. )
Private oF24N  := TFont():New( "Arial", 24, 24,, .T.,,,,  .T., .F. )

opdc := FWMSPrinter():New( zPdf, IMP_PDF, .F., zPathPDF, .T.,, @opdc,,,,, lExibe )
opdc:SetResolution( 72 )
opdc:SetPortrait()
opdc:SetPaperSize( DMPAPER_A4 )
opdc:SetMargin( 50, 50, 50, 50 )
opdc:cPathPDF := zPathPDF

zTotFol := CountPage(aOrdemP)

opdc:StartPage()
PrintCoverPage(aOrdemP, zTotFol)
opdc:EndPage()

PrintPartsList(aOrdemP, zTotFol)

opdc:StartPage()
PrintChecklist(zTotFol, zTotFol)
opdc:EndPage()

If lExibe
    opdc:Preview()
EndIf

Return

// ===========================================================================
//  PÁGINA 1  CAPA
// ===========================================================================
Static Function PrintCoverPage(aOrdemP, nTotFol)

Local cJobNumber  := Substr(aOrdemP[1][2],1,6)
Local cJobQty     := AllTrim(STR(aOrdemP[1][3]))
Local cPartNumber := AllTrim(aOrdemP[1][4])
Local cComplDate  := IIf(!Empty(aOrdemP[1][7]), FormDate(aOrdemP[1][7]), "") 
Local cSeibanNum  := AllTrim(aOrdemP[1][8])
Local cPartDesc   := Substr(aOrdemP[1][5],1,60)
Local xJob        :=   5
Local xQty        :=  50
Local xPart       :=  85
Local xComp       := 152
Local xSeib       := 212
Local xDesc       := 292
Local zLin        := 0

opdc:Say( PGNUM_Y, PGNUM_X, "Página 1 de "+AllTrim(Str(nTotFol)), oF09 )

opdc:SayBitmap(0050, 0010, cLogoTp, 0196, 0087)

zLin := 210

opdc:Say( zLin, 220, "PÁGINA DE CAPA", oF24N )
zLin += 50

opdc:Line( zLin, 0, zLin, PDF_RIGHT )
zLin += 15

opdc:Say( zLin, xJob,  "Ordem",          oF09N )
opdc:Say( zLin, xQty,  "Ordem",          oF09N )
opdc:Say( zLin, xPart, "Numero Peça",    oF09N )
opdc:Say( zLin, xComp, "Data Conclusão", oF09N )
opdc:Say( zLin, xSeib, "Número Seiban",  oF09N )
opdc:Say( zLin, xDesc, "Descrição Peça", oF09N )
zLin += 10

opdc:Say( zLin, xJob, "Número", oF09N )
opdc:Say( zLin, xQty, "Qtde",   oF09N )
zLin += 10

opdc:Line( zLin, 0, zLin, PDF_RIGHT )
zLin += 10

opdc:Say( zLin, xJob,  cJobNumber,  oF09 )
opdc:Say( zLin, xQty,  cJobQty,     oF09 )
opdc:Say( zLin, xPart, cPartNumber, oF09 )
opdc:Say( zLin, xComp, cComplDate,  oF09 )
opdc:Say( zLin, xSeib, cSeibanNum,  oF09 )
opdc:Say( zLin, xDesc, cPartDesc,   oF09 )

zLin += 10

cJobNumber  := Substr(aOrdemP[1][2],7)
cJobQty     := ""
cPartNumber := ""
cComplDate  := ""
cSeibanNum  := ""
cPartDesc   := Substr(aOrdemP[1][5],61,60)

opdc:Say( zLin, xJob,  cJobNumber,  oF09 )
opdc:Say( zLin, xQty,  cJobQty,     oF09 )
opdc:Say( zLin, xPart, cPartNumber, oF09 )
opdc:Say( zLin, xComp, cComplDate,  oF09 )
opdc:Say( zLin, xSeib, cSeibanNum,  oF09 )
opdc:Say( zLin, xDesc, cPartDesc,   oF09 )

Return

// ===========================================================================
//  PÁGINA 2-N  PEÇAS
// ===========================================================================
Static Function PrintPartsList(aOrdemP, nTotFol)

Local aDummy  := {}
Local nI      := 0
Local aRow    := Nil
Local nPage   := 2
Local zLin    := 0
Local nLin    := 0
Local aLinhas := {}
Local nL

For nL := 1 to Len(aOrdemP)
    AAdd(aDummy, { AllTrim(aOrdemP[nL][9]),;
                   AllTrim(aOrdemP[nL][10]),;
                   AllTrim(aOrdemP[nL][15]),;
                   AllTrim(aOrdemP[nL][14]),;
                   aOrdemP[nL][11],;
                   aOrdemP[nL][11] })
Next nL

opdc:StartPage()
zLin := PLPageHeader(nPage, nTotFol)

For nI := 1 To Len( aDummy )

    If zLin + PL_ROW_H > PDF_BOTTOM
        opdc:EndPage()
        nPage += 1
        opdc:StartPage()
        zLin := PLPageHeader( nPage, nTotFol )
    EndIf

    aRow := aDummy[ nI ]

    opdc:Line( zLin, 0, zLin, PDF_RIGHT )
    opdc:Say( zLin + PL_ROW_H/2, PL_C1, aRow[1], oF09 )

    aLinhas = {}
    Q_MemoArray(aRow[2], aLinhas, 40) // 40 caracteres como largura máxima de cada linha

    // Define onde a descriçao vai comecar a ser impressa, considerando o número de linhas que a descrição ocupa para centralizar verticalmente
    nLin = (ZLin + PL_ROW_H/2) - (Len(aLinhas) * 7 / 2) // Ajustando o ponto de início para centralizar a descrição verticalmente, considerando que cada linha adicional ocupa 7 pontos

    // Incrementa sobre o array e imprime cada linha
    For nL := 1 To Len(aLinhas)
        opdc:SayAlign(nLin, PL_C2, aLinhas[nL],oF09,735,,CLR_BLACK,0,0)
        nLin += 7
        If nL >= 5 // Incrementa 5x
            Exit
        Endif
    Next nL

    opdc:Say( zLin + PL_ROW_H/2, PL_C3, aRow[3], oF09 )
    opdc:Say( zLin + PL_ROW_H/2, PL_C4, aRow[4], oF09 )
    opdc:Say( zLin + PL_ROW_H/2, PL_C5, AllTrim(STR(aRow[5])), oF09 )
    opdc:Say( zLin + PL_ROW_H/2, PL_C6, AllTrim(STR(aRow[6])), oF09 )

    zLin += PL_ROW_H

Next nI

opdc:Line( zLin, 0, zLin, PDF_RIGHT )
opdc:EndPage()

Return

// ---------------------------------------------------------------------------
// Cabeçalho das páginas de peças
// ---------------------------------------------------------------------------
Static Function PLPageHeader(nPage, nTotFol)

Local zLin := 0

opdc:Say( PGNUM_Y, PGNUM_X, "Página "+AllTrim(Str(nPage))+" de "+AllTrim(Str(nTotFol)), oF09 )

opdc:SayBitmap(0050, 0010, cLogoTp, 0196, 0087)
zLin := 150

opdc:Say( zLin,  20, "Intralox, L.L.C.",         oF10N )  ;  zLin += 12
opdc:Say( zLin,  20, "1900 Finishing Mill Road", oF10N )  ;  zLin += 12
opdc:Say( zLin,  20, "Suite 104",                oF10N )  ;  zLin += 12
opdc:Say( zLin,  20, "Edgemere, MD 21219",       oF10N )  ;  zLin += 18

zLin += 10

// Caixa de preenchimento para a página toda
opdc:Box(zLin, 0, PDF_BOTTOM, PDF_RIGHT)

//linhas verticais da tabela
opdc:Line(zLin, PL_C2-3, PDF_BOTTOM, PL_C2-3)
opdc:Line(zLin, PL_C3-3, PDF_BOTTOM, PL_C3-3)
opdc:Line(zLin, PL_C4-3, PDF_BOTTOM, PL_C4-3)
opdc:Line(zLin, PL_C5-3, PDF_BOTTOM, PL_C5-3)
opdc:Line(zLin, PL_C6-3, PDF_BOTTOM, PL_C6-3)
opdc:Line(zLin, PL_C7-3, PDF_BOTTOM, PL_C7-3)
opdc:Line(zLin, PL_C8-3, PDF_BOTTOM, PL_C8-3)

zLin += 10

opdc:Say( zLin, PL_C1, "Peça # Intralox",   oF09N )
opdc:Say( zLin, PL_C2, "Descrição",         oF09N )
opdc:Say( zLin, PL_C3, "Peça # Fabricante", oF09N )
opdc:Say( zLin, PL_C4, "Nome Fabricante",   oF09N )
opdc:Say( zLin, PL_C5, "Qtde",              oF09N )
opdc:Say( zLin, PL_C6, "Enviado",           oF09N )
opdc:Say( zLin, PL_C7, "   Bolsa",          oF09N )
opdc:Say( zLin, PL_C8, "   Palete",         oF09N )

zLin += 10

Return(zLin)

// ===========================================================================
//  Ultima Pagina  KU02 CHECKLIST DE KIT DE INTEGRAÇÃO
// ===========================================================================
Static Function PrintChecklist(nPage, nTotFol)

Local cDate     := ""
Local cTopDPP   := ""
Local cSalesOrd := ""
Local aItems    := {}
Local nI        := 0
Local nL        := 0
Local zLin      := 50
Local aLinhas   := {}

AAdd( aItems, "O palete está estruturalmente íntegro com tábuas inferiores, sem rachaduras graves ou pranchas faltando; o palete pode ser levantado com segurança por uma empilhadeira." )
AAdd( aItems, "Os itens estão em boas condições, sem amassados, arranhões ou peças faltando conhecidos. (Correias possuem pinos, tratamentos de pintura estão na cor correta (se fornecidos), ferragens estão no lugar, etc.)" )
AAdd( aItems, "O layout do palete corresponde ao layout fornecido pela Engenharia, se disponível." )
AAdd( aItems, "Peso/itens estão distribuídos uniformemente: o palete tem tamanho adequado para os objetos que contém. Nenhum item sobressaindo ou projetando-se do palete de forma insegura." )
AAdd( aItems, "Itens grandes estão fixados com cintas. Espuma ou plástico bolha é utilizado para proteger itens delicados, itens empilhados e bordas cortantes." )
AAdd( aItems, "Os itens estão identificados com etiqueta 2x4. Itens iguais estão agrupados. A quantidade indicada na etiqueta corresponde à quantidade embalada." )
AAdd( aItems, "Itens pequenos estão em caixas; cada caixa pesa menos de 25 kg e a tampa fecha com segurança. Todas as caixas acima de 25 kg devem ter etiquetas de 'levantamento em equipe' aplicadas." )
AAdd( aItems, "O palete está envolvido de forma segura e completa, cobrindo todos os materiais de ponta a ponta." )
AAdd( aItems, "Uma etiqueta de envio 21x28cm está fixada em ambos os lados do palete embalado, indicando: Quantidade, Número do Pedido de Venda (quando aplicável), Número da Ordem de Trabalho, DPP de nível superior com código de barras, Descrição, Número do palete e Total de paletes." )
AAdd( aItems, "Uma lista de embalagem completa e precisa está anexada ao primeiro palete do kit; as quantidades correspondem ao que foi enviado, o número da ordem de trabalho está presente, e o DPP e a descrição correspondem às etiquetas de envio." )
AAdd( aItems, "Trabalhos que utilizam múltiplos paletes e/ou caixas estão claramente identificados. (ex.: Palete 1 de 2 e Palete 2 de 2, etc.). Etiquetas 'APROVADO PARA ENVIO' foram aplicadas em todos os paletes concluídos." )
AAdd( aItems, "Fotos do kit finalizado (incluindo 1 foto aproximada da etiqueta de envio e uma visão geral do palete completo) foram tiradas para registro." )
AAdd( aItems, "O trabalho foi concluído no Protheus e está pronto para retirada." )

// Caixa Titulo
opdc:Box( zLin, 0, zLin+30, PDF_RIGHT )

zLin += 20
opdc:Say( zLin, 100, "KU02 CHECKLIST DE KIT DE INTEGRAÇÃO", oF24N )
zLin += 20

// Caixa Cabeçalho: DATA | TOP LEVEL DPP# | ORDEM DE VENDA #
opdc:Box( zLin, 0, zLin+20, PDF_RIGHT )
opdc:Line( zLin, 110, zLin+20, 110 )
opdc:Line( zLin, 340, zLin+20, 340 )

zLin += 13
opdc:Say( zLin,   3, "DATA: "+cDate,              oF12N )
opdc:Say( zLin, 120, "DPP# NIVEL TOPO: "+cTopDPP,  oF12N )
opdc:Say( zLin, 350, "ORDEM DE VENDA #: "+cSalesOrd, oF12N )
zLin += 20

// Banner de aviso + iniciais
opdc:Box( zLin, 0, zLin+20, PDF_RIGHT )
opdc:Line( zLin, 490, zLin+20, 490 )
zLin += 14
opdc:Say( zLin, 105, "*Favor verificar todos os passos foram concluídos antes do final do dia.*", oF14N )
opdc:Say( zLin, 510, "INICIAIS", oF14N )
zLin += 20

// Caixa Checklist
For nI := 1 To Len( aItems )
    opdc:Box( zLin, 0, zLin+30, PDF_RIGHT )
    opdc:Line( zLin, 490, zLin+30, 490 )

    aLinhas = {}
    Q_MemoArray(aItems[nI], aLinhas, 125) //usando 125 caracteres como largura máxima de cada linha

    //define onde a descriçao vai comecar a ser impressa, considerando o número de linhas que a descrição ocupa para centralizar verticalmente
    zLin = (ZLin + 30/2) - (Len(aLinhas) * 7 / 2) //ajustando o ponto de início para centralizar a descrição verticalmente, considerando que cada linha adicional ocupa 7 pontos

    // Incrementa sobre o array e imprime cada linha
    For nL := 1 To Len(aLinhas)
        opdc:SayAlign(zLin, 15, aLinhas[nL],oF10,735,,CLR_BLACK,0,0)
        zLin += 7
        if nL >= 4 // Incrementa 4x
            Exit
        Endif
    Next nL

    zLin += 20

Next nI

Return

// ===========================================================================
//  PÁGINA - CONTADOR
// ===========================================================================
Static Function CountPage(aOrdemP)

Local aDummy  := {}
Local nI      := 0
Local aRow    := Nil
Local nPage   := 2
Local zLin    := 0
Local nLin    := 0
Local aLinhas := {}
Local nL

For nL := 1 to Len(aOrdemP)
    AAdd(aDummy, { AllTrim(aOrdemP[nL][9]),;
                   AllTrim(aOrdemP[nL][10]),;
                   AllTrim(aOrdemP[nL][15]),;
                   AllTrim(aOrdemP[nL][14]),;
                   aOrdemP[nL][11],;
                   aOrdemP[nL][11] })
Next nL

zLin := 180 // PLPageHeader(nPage, nTotFol)
For nI := 1 To Len( aDummy )

    If zLin + PL_ROW_H > PDF_BOTTOM
        nPage += 1
        zLin := 180 // PLPageHeader( nPage, nTotFol )
    EndIf

    aRow := aDummy[ nI ]

    aLinhas = {}
    Q_MemoArray(aRow[2], aLinhas, 40) // 40 caracteres como largura máxima de cada linha

    // Incrementa sobre o array e imprime cada linha
    For nL := 1 To Len(aLinhas)
        nLin += 7
        If nL >= 5 // Incrementa 5x
            Exit
        Endif
    Next nL

    zLin += PL_ROW_H

Next nI

Return(nPage)

/*
	// Estrutura:
	// [1]  - Cliente
	// [2]  - Ordem Produção
	// [3]  - Quantidade
	// [4]  - Código Produto
	// [5]  - Descrição Produto
	// [6]  - Previsão Início
	// [7]  - Data Conclusão
	// [8]  - Seiban
	// [9]  - Código Componente
	// [10] - Descrição Componente
	// [11] - Quantidade requerida
	// [12] - Quantidade disponível
	// [13] - Descrição complementar
	// [14] - Fornecedor
	// [15] - Código Produto no Fornecedor

	AAdd(aOrdTmp,{ Substr(cNomCli,1,40),;
				SQL4->D4_OP,;
				SC2->C2_QUANT,;
				SC2->C2_PRODUTO,;
				Posicione("SB1",1,xFilial("SB1")+SC2->C2_PRODUTO,"B1_DESC"),;
				SC2->C2_DATPRI,;
				SC2->C2_DATPRF,;
				IIf( SC2->(FieldPos("C2_XSEIBAN")) > 0, SC2->C2_XSEIBAN, "#SEIBAN" ),;
				SQL4->D4_COD,;
				Posicione("SB1",1,xFilial("SB1")+SQL4->D4_COD,"B1_DESC"),;
				SQL4->D4_QUANT,;
				SB2->B2_QATU,;
				cComplem,;
				cFornec,;
				cPrdFor })
*/


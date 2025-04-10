#include "protheus.ch"
#include "tbiconn.ch"
#include "colors.ch"
#include "rptdef.ch"
#include "FWPrintSetup.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ PDFORDP   ¦ Autor ¦  Fabrica ERPBR    ¦ Data ¦ Nov/2024    ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Pick List ordem de produção modelo Pdf.					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo INTRALOX										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function PDFORDP(aOrdemP, cPathPDF, lExibe)

Local oFont8   := TFont():New("Arial",8,8,,.F.,,,,.T.,.F.)
Local zPathPDF := AllTrim(cPathPdf)+"\"
Local zPdf     := ""
Local zTotFol  := 1
Local nColComp := 50
Local nColDesc := 25
Local aItem
Local pdc, _pdc
Private zLin
Private opdc

If !(FWCodEmp() $("99,U6"))
	MsgAlert("Empresa não autorizada: "+FWCodEmp())
	Return
Endif

If Len(aOrdemP) == 0
	MsgAlert("Sem dados para geração do Pdf.")
	Return
Endif

zPdf := SC2->(C2_NUM+C2_ITEM+C2_SEQUEN)

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

// Contagem de páginas
xLin := 187
zTotFol := 2
For _pdc := 1 to Len(aOrdemP)

    aItem := aOrdemP[_pdc]
    cComp := AllTrim(aItem[9])+" - "+AllTrim(aItem[10])
    cDesc := AllTrim(aItem[13])

    xLin += 17

    nPosIniComp := nColComp + 1
    nPosIniDesc := nColDesc + 1
    lContinue   := .T.

    While lContinue
        lContinue := .F.
        If nPosIniComp <= Len(cComp)
            cDesCol := Substr(cComp, nPosIniComp, nColComp)
            If !Empty(cDesCol)
                lContinue := .T.
            Endif
            nPosIniComp += nColComp
        Endif
        If nPosIniDesc <= Len(cDesc)
            cDesCol := Substr(cDesc, nPosIniDesc, nColDesc)
            If !Empty(cDesCol)
                lContinue := .T.
            Endif
            nPosIniDesc += nColDesc
        Endif
        If lContinue
            xLin += 17
        Endif
    Enddo

    xLin += 13

    If xLin > 750
        zTotFol += 1
        xLin := 187
    Endif

Next _pdc

opdc:=FWMSPrinter():New(zPdf,IMP_PDF,.F.,zPathPDF,.T.,,@opdc,,,,,lExibe)
opdc:SetResolution(72)
opdc:SetPortrait()

opdc:SetPaperSize(DMPAPER_A4)
opdc:SetMargin(60,60,60,60)
opdc:cPathPDF := zPathPDF

opdc:StartPage()
PdfCab(1, zTotFol, aOrdemP)

zFolha := 2
opdc:StartPage()
PdfCab(zFolha, zTotFol, aOrdemP)

For pdc := 1 to Len(aOrdemP)

    aItem := aOrdemP[pdc]
    cComp := AllTrim(aItem[9])+" - "+AllTrim(aItem[10])
    nQtRq := aItem[11]
    nQtDs := aItem[12]
    cDesc := AllTrim(aItem[13])
    cForn := aItem[14]
    cEnde := aItem[15]

    opdc:Box(zLin-5, 010, zLin+5, 020)
    opdc:Say(zLin, 030, Substr(cComp,1,nColComp), oFont8)
    opdc:Say(zLin, 270, AllTrim(STR(nQtRq)), oFont8)
    opdc:Say(zLin, 340, AllTrim(STR(nQtDs)), oFont8)
    opdc:Say(zLin, 400, cForn, oFont8)
    opdc:Say(zLin, 510, cEnde, oFont8)
    zLin += 17

    nPosIniComp := nColComp + 1
    nPosIniDesc := nColDesc + 1
    lContinue   := .T.

    While lContinue
        lContinue := .F.
        If nPosIniComp <= Len(cComp)
            cDesCol := Substr(cComp, nPosIniComp, nColComp)
            If !Empty(cDesCol)
                opdc:Say(zLin, 030, cDesCol, oFont8)
                lContinue := .T.
            Endif
            nPosIniComp += nColComp
        Endif
        /*
        If nPosIniDesc <= Len(cDesc)
            cDesCol := Substr(cDesc, nPosIniDesc, nColDesc)
            If !Empty(cDesCol)
                opdc:Say(zLin, 310, cDesCol, oFont8)
                lContinue := .T.
            Endif
            nPosIniDesc += nColDesc
        Endif
        */
        If lContinue
            zLin += 17
        Endif
    Enddo

    zLin += 13

    If zLin > 750
        opdc:Line(zLin, 0000, zLin, 0560)
        opdc:EndPage()
        zFolha += 1
        opdc:StartPage()
        PdfCab(zFolha, zTotFol, aOrdemP)
        zLin := 210
    Endif

Next pdc

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
¦¦¦Funcao    ¦ PdfCab  ¦ Autor ¦  Fabrica ERPBR    ¦ Data ¦ 02/11/2024	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Impressão do cabeçalho.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo INTRALOX										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function PdfCab(zFolha, zTotFol, aOrdemP)

Local cStartPath := GetSrvProfString("Startpath","")
Local cLogoTp := cStartPath + "logo_intraloxU6.bmp"
Local oFont8   := TFont():New("Arial",8,8,,.F.,,,,.T.,.F.)
Local oFont10  := TFont():New("Arial",12,12,,.F.,,,,.T.,.F.)
Local oFont24  := TFont():New("Arial",24,24,,.F.,,,,.T.,.F.)

xClient := aOrdemP[1][1]
xOrdemP := aOrdemP[1][2]
xQuanti := AllTrim(STR(aOrdemP[1][3]))
xProdut := aOrdemP[1][4]
xDescri := AllTrim(aOrdemP[1][5])
xDatIni := FormDate(aOrdemP[1][6])
xDatEnt := FormDate(aOrdemP[1][7])
xSeiban := aOrdemP[1][8]

opdc:Say(810, 250, "Impresso em "+FormDate(Date())+" às "+Time()+Space(20)+"Folha: "+AllTrim(STR(zFolha))+" de "+AllTrim(STR(zTotFol)),oFont10)

If zFolha == 1
    opdc:SayBitmap(0070, 0140, cLogoTp, 0280, 0170)
	zLin := 300
    opdc:Say(zLin, 030, "Cliente: "+xClient,oFont24)
	zLin += 40
	opdc:Say(zLin, 030, "Ordem de Produção: "+xOrdemP,oFont24)
	zLin += 40
	opdc:Say(zLin, 030, "Quantidade: "+xQuanti,oFont24)
	zLin += 40
	opdc:Say(zLin, 030, "Código: "+xProdut,oFont24)
	zLin += 40

    xDesc01 := AllTrim(Substr(xDescri,1,40))
    xDesc02 := AllTrim(Substr(xDescri,41,40))
    xDesc03 := AllTrim(Substr(xDescri,81,40))
    opdc:Say(zLin, 030, xDesc01,oFont24)
	zLin += 40
    If !Empty(xDesc02)
        opdc:Say(zLin, 030, xDesc02,oFont24)
        zLin += 40
    Endif
    If !Empty(xDesc03)
        opdc:Say(zLin, 030, xDesc03,oFont24)
        zLin += 40
    Endif

	opdc:Say(zLin, 030, "Previsão de Início: "+xDatIni,oFont24)
	zLin += 40
	opdc:Say(zLin, 030, "Data de Entrega: "+xDatEnt,oFont24)
	zLin += 40
	opdc:Say(zLin, 030, "Seiban #: "+xSeiban,oFont24)
	opdc:EndPage()
Else
	zLin := 34
	opdc:Say(zLin, 160, "Cliente: "+xClient,oFont8)
	zLin += 17
	opdc:Say(zLin, 160, "Ordem de Produção: "+xOrdemP,oFont8)
	opdc:Say(zLin, 310, "Quantidade: "+xQuanti,oFont8)
	zLin += 17
	opdc:Say(zLin, 160, "Código: "+xProdut,oFont8)
	zLin += 17

    xDesc01 := AllTrim(Substr(xDescri,1,60))
    xDesc02 := AllTrim(Substr(xDescri,61,60))
	opdc:Say(zLin, 160, xDesc01,oFont8)
	zLin += 17
    If !Empty(xDesc02)
        opdc:Say(zLin, 160, xDesc02,oFont8)
        zLin += 17
    Endif

	opdc:Say(zLin, 160, "Previsão de Início: "+xDatIni,oFont8)
	opdc:Say(zLin, 310, "Data de Entrega: "+xDatEnt,oFont8)
	zLin += 17
	opdc:Say(zLin, 160, "Seiban #: "+xSeiban,oFont8)
	zLin += 17
	opdc:Line(zLin, 0000, zLin, 0560)
	opdc:SayBitmap(0040, 0000, cLogoTp, 0132, 0078)
    //
    zLin += 17
    opdc:Say(zLin, 270, "QTD", oFont8, , CLR_HRED)
    opdc:Say(zLin, 340, "QTD", oFont8, , CLR_HRED)
    zLin += 17
    opdc:Say(zLin, 030, "COMPONENTE", oFont8, , CLR_HRED)
    opdc:Say(zLin, 270, "REQUERIDA", oFont8, , CLR_HRED)
    opdc:Say(zLin, 340, "DISPONÍVEL", oFont8, , CLR_HRED)
    opdc:Say(zLin, 400, "FORNECEDOR", oFont8, , CLR_HRED)
    opdc:Say(zLin, 510, "ENDEREÇO", oFont8, , CLR_HRED)
    zLin += 17
Endif

Return

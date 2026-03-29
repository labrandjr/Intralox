#include "totvs.ch"
#include "protheus.ch"

/*/{Protheus.doc} 
@function MT010BRW
@description Adiciona botões no browse de produtos
@type function
@author	Fábrica ERP.BR
@since 21/03/2026
@version P12
@database MSSQL
/*/
User Function MT010BRW()

Local aRotUser := {}

AAdd( aRotUser, { "Certificado BOM", "u_ExeCertBom()", 0, 4 } )

Return(aRotUser)

/*/{Protheus.doc} 
@function ExeCertBom
@description Executa processamento
@type function
@author	Fábrica ERP.BR
@since 21/03/2026
@version P12
@database MSSQL
/*/
User Function ExeCertBom()

FwMsgRun(, { || u_IntCertBom() },,"Emitindo certificado BOM... aguarde")

Return

/*/{Protheus.doc} 
@function IntCertBom
@description Checagem de movimentos
@type function
@author	Fábrica ERP.BR
@since 21/03/2026
@version P12
@database MSSQL
/*/
User Function IntCertBom()

Local aArea    := FwGetArea()
Local cCodProd := SB1->B1_COD
Local nQuant   := 1
Local nCount   := 0

// Variáveis Private para utilização da função Estrut2
Private oTempTable := Nil
Private cAliasTmp  := "ESTRUT"
Private nEstru     := 0
Private oTemp1

// Cria a estrutura temporária de extração
pCriaTemp()

// Cria a estrutura temporária de processamento
Estrut2(cCodProd, nQuant, cAliasTmp, @oTempTable) // , .T., .F., .T.)

(cAliasTmp)->(DbGoTop())
If !(cAliasTmp)->(Eof())

	While !(cAliasTmp)->(Eof())

        cLocPad := "01"
        DbSelectArea("SB1")
        DbSetOrder(1)
        DbSeek( xFilial("SB1") + (cAliasTmp)->COMP )

        nCmComp := 0
        DbSelectArea("SB2")
        DbSetOrder(1)
        If DbSeek( xFilial("SB2") + (cAliasTmp)->COMP + SB1->B1_LOCPAD )
            nCmComp := SB2->B2_CM1
        Else
            If DbSeek( xFilial("SB2") + (cAliasTmp)->COMP + cLocPad )
                nCmComp := SB2->B2_CM1
            Endif
        Endif

        nCount += 1
        DbSelectArea("TR1")
        RecLock("TR1",.T.)
        TR1->T1_ORDEM  := StrZero(nCount,10)
        TR1->T1_CODFIM := cCodProd //(cAliasTmp)->CODIGO
        TR1->T1_CODIGO := (cAliasTmp)->CODIGO
        TR1->T1_COMP   := (cAliasTmp)->COMP
        TR1->T1_NIVEL  := (cAliasTmp)->NIVEL
        TR1->T1_QUANT  := (cAliasTmp)->QUANT
        TR1->T1_ORIGEM := SB1->B1_ORIGEM
        TR1->T1_POSIPI := SB1->B1_POSIPI
        TR1->T1_CUSUNI := nCmComp
        TR1->T1_CUSTOT := TR1->(T1_QUANT * T1_CUSUNI)
        TR1->T1_DESCRI := SB1->B1_DESC
        MsUnLock()

        DbSelectArea(cAliasTmp)
		(cAliasTmp)->(DbSkip())
	Enddo

Else

	FwAlertError("Estrutura não encontrada!","Aviso")

Endif

FimEstrut2(cAliasTmp, @oTempTable)

If nCount > 1
    GeraExcel(cCodProd)
Endif

FwRestArea(aArea)

TR1->(DbCloseArea())
oTemp1:Delete()

Return

/*/{Protheus.doc} 
@function pCriaTemp
@description Cria estrutura temporária de extração
@type function
@author	Fábrica ERP.BR
@since 21/03/2026
@version P12
@database MSSQL
/*/
Static Function pCriaTemp()

Local _aTmp1 := {}

oTemp1 := FWTemporaryTable():New("TR1")

AAdd ( _aTmp1, {"T1_ORDEM"  , "C", 10, 00} )
AAdd ( _aTmp1, {"T1_CODFIM" , "C", TamSx3("B1_COD")[1], 00} )
AAdd ( _aTmp1, {"T1_CODIGO" , "C", TamSx3("B1_COD")[1], 00} )
AAdd ( _aTmp1, {"T1_COMP"   , "C", TamSx3("B1_COD")[1], 00} )
AAdd ( _aTmp1, {"T1_NIVEL"  , "C", 06, 00} )
AAdd ( _aTmp1, {"T1_QUANT"  , "N", TamSx3("G1_QUANT")[1], TamSx3("G1_QUANT")[2]} )
AAdd ( _aTmp1, {"T1_ORIGEM" , "C", TamSx3("B1_ORIGEM")[1], 00} )
AAdd ( _aTmp1, {"T1_POSIPI" , "C", TamSx3("B1_POSIPI")[1], 00} )
AAdd ( _aTmp1, {"T1_CUSUNI" , "N", TamSx3("B2_CM1")[1], TamSx3("B2_CM1")[2]} )
AAdd ( _aTmp1, {"T1_CUSTOT" , "N", TamSx3("B2_VATU1")[1], TamSx3("B2_VATU1")[2]} )
AAdd ( _aTmp1, {"T1_DESCRI" , "C", TamSx3("B1_DESC")[1], 00} )
oTemp1:SetFields( _aTmp1 )
oTemp1:AddIndex("indice1", {"T1_ORDEM"})
oTemp1:Create()

Return

/*/{Protheus.doc} GeraExcel
@type function
@author	Fábrica ERP.BR
@since 21/03/2026
@version P12
@database MSSQL
@Descricao: Envia email
/*/
Static Function GeraExcel(cCodProd)

Local oExcel   := FwMsExcelXLSX():New()
Local cArqXls  := "Certificado "+AllTrim(cCodProd)+"_"+Dtos(Date())+"_"+StrTran(Time(),":","")+".xlsx"
Local cDefPath := GetSrvProfString("StartPath","\system\")
Local cPath    := GetTempPath()

cNomePlan  := "certificado_bom"
cNomeTable := "Certificado BOM"
oExcel:AddworkSheet(cNomePlan)
oExcel:AddTable(cNomePlan,cNomeTable,.F.)

oExcel:AddColumn(cNomePlan,cNomeTable,"Código item final (FG)",1,1)
oExcel:AddColumn(cNomePlan,cNomeTable,"Nível",1,1)
oExcel:AddColumn(cNomePlan,cNomeTable,"Código item",1,1)
oExcel:AddColumn(cNomePlan,cNomeTable,"Composição (PN)",1,1)
oExcel:AddColumn(cNomePlan,cNomeTable,"Qty",3,1)
oExcel:AddColumn(cNomePlan,cNomeTable,"Origem/CST",1,1)
oExcel:AddColumn(cNomePlan,cNomeTable,"NCM",1,1)
oExcel:AddColumn(cNomePlan,cNomeTable,"C unit (R$)",3,3)
oExcel:AddColumn(cNomePlan,cNomeTable,"C total (R$)",3,3)
oExcel:AddColumn(cNomePlan,cNomeTable,"Descrição",1,1)

DbSelectArea("TR1")
TR1->(DbGoTop())
While !Eof()

	oExcel:AddRow(cNomePlan, cNomeTable, { AllTrim(TR1->T1_CODFIM),;
                                           AllTrim(TR1->T1_NIVEL),;
                                           AllTrim(TR1->T1_CODIGO),;
                                           AllTrim(TR1->T1_COMP),;
                                           TR1->T1_QUANT,;
                                           TR1->T1_ORIGEM,;
                                           Transform(TR1->T1_POSIPI,"@R 9999.99.99"),;
                                           TR1->T1_CUSUNI,;
                                           TR1->T1_CUSTOT,;
                                           AllTrim(TR1->T1_DESCRI) })
    DbSelectArea("TR1")
    TR1->(DbSkip())
Enddo

oExcel:Activate()
oExcel:GetXmlFile(cArqXls)

CpyS2t(cDefPath+cArqXls, cPath)
oExcelApp := MsExcel():New()
oExcelApp:WorkBooks:Open(cPath+cArqXls)
oExcelApp:SetVisible(.T.)
oExcelApp:Destroy()

Return

// ESTRUT2 - Explosão de estrutura cadastrada no SG1
// https://tdn.totvs.com/pages/releaseview.action?pageId=287060852

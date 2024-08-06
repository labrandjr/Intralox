#include "rwmake.ch"
#include "protheus.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ A140IGRV  ¦ Autor ¦ Fábrica ERP.BR  ¦  Data  ¦ Jun/2023    ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ 4-Manipular dados da SDS/SDT na importação de uma NFE.     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo INTRALOX										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function A140IGRV()

Local aArea   := GetArea()
Local lImpXml := GetMv("MV_IMPXML")
Local aParam  := PARAMIXB
Local lAltEsp := SuperGetMv("MV_ZALTESP",.F.,.T.)

If lImpXml .And. FWCodEmp() $("99,U6")

    zDoc := aParam[1]
    zSer := aParam[2]
    zFor := aParam[3]
    zLoj := aParam[4]
    oXml := aParam[5]

    // 1 - Espécie do Documento
    If lAltEsp .And. FWCodEmp() == "U6"
        DbSelectArea("SDS")
        DbSetOrder(1)
        If DbSeek( xFilial("SDS") + zDoc + zSer + zFor + zLoj )
            If SDS->DS_TIPO == "N"
                RecLock("SDS",.F.)
                SDS->DS_ESPECI := "NF-E"
                MsUnLock()
            Endif
        Endif
    Endif

    // 2 - Associação com Pedido de Compra
    DbSelectArea("SDS")
    DbSetOrder(1)
    If DbSeek( xFilial("SDS") + zDoc + zSer + zFor + zLoj )
        If SDS->DS_TIPO == "N"
            DbSelectArea("SDT")
            DbSetOrder(8)
            If DbSeek( xFilial("SDT") + zFor + zLoj + zDoc + zSer )
                While !Eof() .And. SDT->(DT_FILIAL+DT_FORNEC+DT_LOJA+DT_DOC+DT_SERIE) == xFilial("SDT") + zFor + zLoj + zDoc + zSer
                    If Empty(SDT->DT_PEDIDO)
                        aPedCom := GetPedCom(SDT->DT_FORNEC, SDT->DT_LOJA, SDT->DT_COD, SDT->DT_QUANT, SDT->DT_ITEM, oXml)
                        If Len(aPedCom) > 0
                            RecLock("SDT",.F.)
                            SDT->DT_PEDIDO := aPedCom[1]
                            SDT->DT_ITEMPC := aPedCom[2]
                            MsUnLock()
                        Endif
                    Endif
                    DbSelectArea("SDT")
                    SDT->(DbSkip())
                Enddo
            Endif
        Endif
    Endif        

Endif

RestArea(aArea)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ GetPedCom ¦ Autor ¦ Fábrica ERP.BR  ¦  Data  ¦ Jun/2023    ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Busca pedido de compra em aberto.                          ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo INTRALOX										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function GetPedCom(xFornec, xLoja, xProduto, xQuant, xItem, oXml)

Local aArea := GetArea()
Local aRetPed := {}
Local lLocPed := .F.
Local xPedXml := ""
Local _det

//1. Tenta localizar pelas Tags Xml
aDet := oXml:_INFNFE:_DET
If ValType(aDet) == "A"
    For _det := 1 to Len(aDet)
        If _det == Val(xItem)
            If ValType( XmlChildEx(aDet[_det]:_PROD,"_XPED") ) == "O"
                xPedXml := PadR(aDet[_det]:_PROD:_XPED:TEXT,6)
                Exit
            Endif
        Endif
    Next _det
ElseIf ValType(aDet) == "O"
    If ValType( XmlChildEx(aDet:_PROD,"_XPED") ) == "O"
        xPedXml := PadR(aDet:_PROD:_XPED:TEXT,6)
    Endif
Endif
If !Empty(xPedXml)
    cQry := " SELECT C7_NUM, C7_ITEM "
    cQry += " FROM "+RetSqlName("SC7")
    cQry += " WHERE C7_FILIAL = '"+xFilial("SC7")+"' "
    cQry += " AND C7_NUM = '"+xPedXml+"' "
    cQry += " AND C7_FORNECE = '"+xFornec+"' "
    cQry += " AND C7_LOJA = '"+xLoja+"' "
    cQry += " AND C7_PRODUTO = '"+xProduto+"' "
    cQry += " AND (C7_QUANT - C7_QUJE - C7_QTDACLA) >= "+AllTrim(STR(xQuant))
    cQry += " AND C7_ENCER <> 'E' "
    cQry += " AND C7_RESIDUO <> 'S' "
    cQry += " AND D_E_L_E_T_ <> '*' "
    cQry += " ORDER BY C7_EMISSAO, C7_NUM, C7_ITEM "
    cQry := ChangeQuery(cQry)
    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQry),"PED", .T., .T.)
    DbSelectArea("PED")
    PED->(DbGotop())
    If PED->(!Eof())
        lLocPed := .T.
        AAdd(aRetPed, PED->C7_NUM)
        AAdd(aRetPed, PED->C7_ITEM)
    Endif
    PED->(DbCloseArea())
Endif

//2. Tenta localizar por fornecedor x produto
If !lLocPed
    cQry := " SELECT C7_NUM, C7_ITEM "
    cQry += " FROM "+RetSqlName("SC7")
    cQry += " WHERE C7_FILIAL = '"+xFilial("SC7")+"' "
    cQry += " AND C7_FORNECE = '"+xFornec+"' "
    cQry += " AND C7_LOJA = '"+xLoja+"' "
    cQry += " AND C7_PRODUTO = '"+xProduto+"' "
    cQry += " AND (C7_QUANT - C7_QUJE - C7_QTDACLA) >= "+AllTrim(STR(xQuant))
    cQry += " AND C7_ENCER <> 'E' "
    cQry += " AND C7_RESIDUO <> 'S' "
    cQry += " AND D_E_L_E_T_ <> '*' "
    cQry += " ORDER BY C7_EMISSAO, C7_NUM, C7_ITEM "
    cQry := ChangeQuery(cQry)
    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQry),"PED", .T., .T.)

    DbSelectArea("PED")
    PED->(DbGotop())
    If PED->(!Eof())
        lLocPed := .T.
        AAdd(aRetPed, PED->C7_NUM)
        AAdd(aRetPed, PED->C7_ITEM)
    Endif
    PED->(DbCloseArea())
Endif

// 3. Tenta entrega por terceiros
If !lLocPed
    DbSelectArea("CPX")
    DbSetOrder(1)
    If DbSeek( xFilial("CPX") + xFornec + xLoja )
        While !Eof() .And. CPX->(CPX_FILIAL+CPX_CODIGO+CPX_LOJA) == xFilial("CPX") + xFornec + xLoja

            cQry := " SELECT C7_NUM, C7_ITEM "
            cQry += " FROM "+RetSqlName("SC7")
            cQry += " WHERE C7_FILIAL = '"+xFilial("SC7")+"' "
            cQry += " AND C7_FORNECE = '"+CPX->CPX_CODFOR+"' "
            cQry += " AND C7_LOJA = '"+CPX->CPX_LOJFOR+"' "
            cQry += " AND C7_PRODUTO = '"+xProduto+"' "
            cQry += " AND (C7_QUANT - C7_QUJE - C7_QTDACLA) >= "+AllTrim(STR(xQuant))
            cQry += " AND C7_ENCER <> 'E' "
            cQry += " AND C7_RESIDUO <> 'S' "
            cQry += " AND D_E_L_E_T_ <> '*' "
            cQry += " ORDER BY C7_EMISSAO, C7_NUM, C7_ITEM "
            cQry := ChangeQuery(cQry)
            DbUseArea(.T., "TOPCONN", TCGenQry(,,cQry),"PED", .T., .T.)

            DbSelectArea("PED")
            PED->(DbGotop())
            If PED->(!Eof())
                lLocPed := .T.
                AAdd(aRetPed, PED->C7_NUM)
                AAdd(aRetPed, PED->C7_ITEM)
            Endif
            PED->(DbCloseArea())

            If lLocPed
                Exit
            Endif

            DbSelectArea("CPX")
            CPX->(DbSkip())
        Enddo
    Endif
Endif

RestArea(aArea)

Return(aRetPed)

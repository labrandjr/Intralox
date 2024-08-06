#include "rwmake.ch"
#include "protheus.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ A140IPRD ¦ Autor ¦ Fábrica ERP.BR   ¦  Data  ¦ Jun/2023    ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ 1-Identificação do Produto.                				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo INTRALOX										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function A140IPRD()

Local aArea    := GetArea()
Local lImpXml  := GetMv("MV_IMPXML")
Local zCodigo  := PARAMIXB[1]
Local zLoja    := PARAMIXB[2]
Local zPrdXml  := PARAMIXB[3]
Local oDetItem := PARAMIXB[4]
Local zParam5  := PARAMIXB[5]
Local oXmlPar  := PARAMIXB[6]
Local cNewPrd  := Space(15)

If lImpXml .And. FWCodEmp() $("99,U6")

    oXmlNfe := oXmlPar
    zAliasP := zParam5
    zPrdFor := zPrdXml
    zDescri := AllTrim(oDetItem:_PROD:_XPROD:TEXT)
    zCodPrd := ""
    lCodPrd := .F.

    // 1. Tenta localizar pelo código do produto do fornecedor = código do produto no Protheus
    DbSelectArea("SB1")
    DbSetOrder(1)
    If DbSeek( xFilial("SB1") + PadR(zPrdFor,TamSx3("B1_COD")[1]) )
        zCodPrd := zPrdFor
        lCodPrd := .T.
    Endif

    // 2. Tenta localizar pela descrição do produto no fornecedor = contém o código do produto no Protheus
    If !lCodPrd
        nPosDPP := AT("DPP-",zDescri)
        If nPosDPP > 0
            zCodPrd := "DPP-"+Substr(zDescri,nPosDPP+4,7)
            lCodPrd := .T.
        Endif
    Endif

    If !lCodPrd
        nPosDPE := AT("DPE-",zDescri)
        If nPosDPE > 0
            zCodPrd := "DPE-"+Substr(zDescri,nPosDPE+4,7)
            lCodPrd := .T.
        Endif
    Endif

    // 3. Tenta localizar nas informações adicionais do produto = contém o código do produto no Protheus
    If !lCodPrd
        If ValType( XmlChildEx(oDetItem,"_INFADPROD") ) == "O"
            zInfAdd := oDetItem:_INFADPROD:TEXT
            nPosDPP := AT("DPP-",zInfAdd)
            If nPosDPP > 0
                zCodPrd := "DPP-"+Substr(zInfAdd,nPosDPP+4,7)
                zCodPrd := PadR(zCodPrd,TamSx3("B1_COD")[1])
                DbSelectArea("SB1")
                DbSetOrder(1)
                If DbSeek( xFilial("SB1") + zCodPrd )
                    lCodPrd := .T.
                Else
                    zCodPrd := "DPP-"+Substr(zInfAdd,nPosDPP+4,8)
                    zCodPrd := PadR(zCodPrd,TamSx3("B1_COD")[1])
                    DbSelectArea("SB1")
                    DbSetOrder(1)
                    If DbSeek( xFilial("SB1") + zCodPrd )
                        lCodPrd := .T.
                    Endif
                Endif
            Endif
            If !lCodPrd
                nPosDPE := AT("DPE-",zInfAdd)
                If nPosDPE > 0
                    zCodPrd := "DPE-"+Substr(zInfAdd,nPosDPE+4,7)
                    zCodPrd := PadR(zCodPrd,TamSx3("B1_COD")[1])
                    DbSelectArea("SB1")
                    DbSetOrder(1)
                    If DbSeek( xFilial("SB1") + zCodPrd )
                        lCodPrd := .T.
                    Else
                        zCodPrd := "DPE-"+Substr(zInfAdd,nPosDPE+4,8)
                        zCodPrd := PadR(zCodPrd,TamSx3("B1_COD")[1])
                        DbSelectArea("SB1")
                        DbSetOrder(1)
                        If DbSeek( xFilial("SB1") + zCodPrd )
                            lCodPrd := .T.
                        Endif    
                    Endif    
                Endif
            Endif
        Endif
    Endif

    If lCodPrd
        zCodPrd := PadR(zCodPrd,TamSx3("B1_COD")[1])
        DbSelectArea("SB1")
        DbSetOrder(1)
        If DbSeek( xFilial("SB1") + zCodPrd )
            DbSelectArea("SA2")
            DbSetOrder(1)
            If DbSeek( xFilial("SA2") + zCodigo + zLoja )
                DbSelectArea("SA5")
                DbSetOrder(1)
                If !DbSeek( xFilial("SA5") + SA2->A2_COD + SA2->A2_LOJA + SB1->B1_COD )
                    RecLock("SA5",.T.)
                    SA5->A5_FILIAL	:= xFilial("SA5")
                    SA5->A5_FORNECE	:= SA2->A2_COD
                    SA5->A5_LOJA	:= SA2->A2_LOJA
                    SA5->A5_NOMEFOR	:= SA2->A2_NOME
                    SA5->A5_PRODUTO	:= SB1->B1_COD
                    SA5->A5_NOMPROD	:= SB1->B1_DESC
                    SA5->A5_CODPRF  := zPrdFor
                    SA5->A5_CHAVE   := A060Chave()
                    MsUnLock()
                Else
                    RecLock("SA5",.F.)
                    SA5->A5_CODPRF := zPrdFor
                    MsUnLock()
                Endif
            Endif
        Endif
    Endif

Endif

RestArea(aArea)

Return(cNewPrd)

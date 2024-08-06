#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "rwmake.CH"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MA150BUT  ¦ Autor ¦ Fábrica ERPBR    ¦   Data  ¦ Jun/2023  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Adiciona botões na cotação.          					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo INTRALOX 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MA150BUT()

Local aButtons := {}

If FWCodEmp() $("99,U6")
    AAdd(aButtons,{"RPMCPO", {|| A150Check() },"Replicar dados", "Replicar dados"})
Endif    

Return(aButtons)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MA150BUT  ¦ Autor ¦ Fábrica ERPBR    ¦   Data  ¦ Jun/2023  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Adiciona botões na cotação.          					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo INTRALOX 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function A150Check()

Local nOpcChk := 0
Local bOkChk  := {|| nOpcChk:=1,oDlgChk:End() }
Local bCanChk := {|| nOpcChk:=0,oDlgChk:End() }
Local oDlgChk

Private lCheck1 := .F.
Private lCheck2 := .F.
Private lCheck3 := .F.
Private lCheck4 := .F.
Private oCheck1, oCheck2, oCheck3, oCheck4

nDlg1 := 001
nDlg2 := 001
nDlg3 := 200
nDlg4 := 376

oDlgChk := MsDialog():New(nDlg1,nDlg2,nDlg3,nDlg4,"Selecione as colunas",,,,,CLR_BLACK,CLR_WHITE,,,.T.)

@ 035,005 TO 090,185 LABEL "" OF oDlgChk PIXEL
oCheck1 := TCheckBox():New(045,010,"Tab.Preço"    ,{|u|IIf(PCount()>0,lCheck1:=u,lCheck1)},oDlgChk,100,210,,,,,,,,.T.,,,)
oCheck2 := TCheckBox():New(055,010,"Prazo Entreg" ,{|u|IIf(PCount()>0,lCheck2:=u,lCheck2)},oDlgChk,100,210,,,,,,,,.T.,,,)
oCheck3 := TCheckBox():New(065,010,"Aliq. IPI"    ,{|u|IIf(PCount()>0,lCheck3:=u,lCheck3)},oDlgChk,100,210,,,,,,,,.T.,,,)
oCheck4 := TCheckBox():New(075,010,"Aliq. ICMS"   ,{|u|IIf(PCount()>0,lCheck4:=u,lCheck4)},oDlgChk,100,210,,,,,,,,.T.,,,)

oDlgChk:Activate(,,,.T.,{|| _VldCheck() },,{|| EnchoiceBar(oDlgChk,bOkChk,bCanChk) } )

If nOpcChk == 1
    A150Replica(lCheck1, lCheck2, lCheck3, lCheck4)
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ _VldCheck   ¦ Autor ¦ Fábrica ERPBR  ¦   Data  ¦ Jun/2023  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Valida opções selecionadas.             					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo INTRALOX 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function _VldCheck()

Local lRetChk := .T.

If !lCheck1 .And. !lCheck2 .And. !lCheck3 .And. !lCheck4
    MsgAlert("Nenhuma opção selecionada.")
    lRetChk := .F.
Endif

Return(lRetChk)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ A150Replica ¦ Autor ¦ Fábrica ERPBR  ¦   Data  ¦ Jun/2023  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Replica dados no aCols.                					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo INTRALOX 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function A150Replica(lCheck1, lCheck2, lCheck3, lCheck4)

Local aArea   := GetArea()
Local nPosTab := aScan(aHeader,{|x|Alltrim(x[2])=="C8_CODTAB"})
Local nPosPrz := aScan(aHeader,{|x|Alltrim(x[2])=="C8_PRAZO"})
Local nPosIpi := aScan(aHeader,{|x|Alltrim(x[2])=="C8_ALIIPI"})
Local nPosIcm := aScan(aHeader,{|x|Alltrim(x[2])=="C8_PICM"})
Local nPosPrc := aScan(aHeader,{|x|Alltrim(x[2])=="C8_PRECO"})
Local _BkpN := N
Local _x

zCodTab := aCols[1][nPosTab]
zPrzEnt := aCols[1][nPosPrz]
zAlqIpi := aCols[1][nPosIpi]
zAlqIcm := aCols[1][nPosIcm]

For _x := 1 to Len(aCols)
    N := _x
    If !aCols[_x][Len(aHeader)+1]
        
        If lCheck1
            aCols[_x][nPosTab] := zCodTab
            I150Tabela("C8_CODTAB",zCodTab)
            MaFisRef("IT_PRCUNI","MT150",aCols[_x][nPosPrc])
        Endif

        If lCheck2
            If Empty(aCols[_x][nPosPrz])
                aCols[_x][nPosPrz] := zPrzEnt
            Endif
        Endif
        
        If lCheck3
            If aCols[_x][nPosIpi] == 0
                aCols[_x][nPosIpi] := zAlqIpi
                MaFisRef("IT_ALIQIPI","MT150",zAlqIpi)
            Endif
        Endif

        If lCheck4
            If aCols[_x][nPosIcm] == 0
                aCols[_x][nPosIcm] := zAlqIcm
                MaFisRef("IT_ALIQICM","MT150",zAlqIcm)
            Endif
        Endif

        Eval(bRefresh)

    Endif
Next _x

N:= _BkpN
RestArea(aArea)

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ I150Tabela ¦ Autor ¦ Fábrica ERPBR  ¦   Data  ¦ Jun/2023   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Atualiza preço unitário conforme tabela de preço.          ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo INTRALOX 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function I150Tabela(cReadVar,xConteudo)

Local aArea     := GetArea()
Local aAreaSB1  := SB1->(GetArea())
Local nPCodTab  := aScan(aHeader,{|x| AllTrim(x[2])=="C8_CODTAB"})
Local nPProduto := aScan(aHeader,{|x| AllTrim(x[2])=="C8_PRODUTO"})
Local nPQuant   := aScan(aHeader,{|x| AllTrim(x[2])=="C8_QUANT"})
Local nPPreco   := aScan(aHeader,{|x| AllTrim(x[2])=="C8_PRECO"})
Local nPAVista  := aScan(aHeader,{|x| AllTrim(x[2])=="C8_AVISTA"})
Local nPTxFor   := aScan(aHeader,{|x| AllTrim(x[2])=="C8_TAXAFOR"})
Local nPTotal   := aScan(aHeader,{|x| AllTrim(x[2])=="C8_TOTAL"})
Local nPFrete   := aScan(aHeader,{|x| AllTrim(x[2])=="C8_VALFRE"})
Local nPrcCom	:= aCols[N][nPPreco]
Local nQtde     := aCols[N][nPQuant]
Local cProduto  := aCols[N][nPProduto]
Local cCodTab   := ""
Local nValFrete := 0
Local lAtuFrete := .F.

DEFAULT cReadVar  := ReadVar()
DEFAULT xConteudo := &(ReadVar())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o campo de tabela de preco esta ativo            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nPCodTab > 0
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Verifica qual o campo ativo na getdados                      ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    Do Case
    Case "C8_CODTAB"$cReadVar
        cCodTab := xConteudo

        //Atualiza aCols
        aCols[n,nPCodTab] := xConteudo
    Case "C8_PRODUTO"$cReadVar
        cProduto := xConteudo
    Case "C8_QUANT"$cReadVar
        nQtde := xConteudo
    EndCase

    dbSelectArea("SB1")
    dbSetOrder(1)
    If ( !Empty(cProduto) .And. MsSeek(xFilial("SB1")+cProduto,.F.) .and. !Empty(cCodTab))
        nPrcCom := MaTabPrCom(cCodTab,cProduto,nQtde,cA150Forn,cA150Loj,nMoedaCot,dA150Emis,nTxMoeda,@nValFrete)
    EndIf
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Atualiza a funcao fiscal                                     ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If nPAVista > 0
        aCols[N][nPAVista] := nPrcCom
    EndIf
    If nPAVista > 0 .And. nPTxFor > 0 .And. aCols[n][nPTxFor] > 0
        nPrcCom	 := a150FV(nPrcCom,aCols[n][nPTxFor])
        nValFrete:= a150FV(nValFrete,aCols[n][nPTxFor])
    EndIf
    aCols[N][nPPreco] := nPrcCom
    If nPFrete > 0 .And. nValFrete != aCols[N][nPFrete]
        aCols[N][nPFrete] := nValFrete
        lAtuFrete          := .T.
    EndIf

    If MaFisFound("IT",N)
        MaFisRef("IT_PRCUNI","MT150",nPrcCom)
        If lAtuFrete
            MaFisRef("IT_FRETE","MT150",nValFrete)
        EndIf
    EndIf
    If Abs(aCols[n][nPTotal]-NoRound(aCols[n][nPPreco]*aCols[n][nPQuant],TamSx3("C8_TOTAL")[2]))<>0.09
        aCols[n][nPTotal] := NoRound(aCols[n][nPPreco]*aCols[n][nPQuant],TamSx3("C8_TOTAL")[2])
        If MaFisFound("IT",N)
            MaFisRef("IT_VALMERC","MT150",aCols[n][nPTotal])
        EndIf
    EndIf
//    If ExistTrigger("C8_PRECO")
//        RunTrigger(2,N)
//    EndIf
//    If ExistTrigger("C8_VALFRE")
//        RunTrigger(2,N)
//    EndIf
EndIf

RestArea(aAreaSB1)
RestArea(aArea)

Return(.T.)

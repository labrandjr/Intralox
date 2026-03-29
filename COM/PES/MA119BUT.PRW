#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "rwmake.CH"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ MA119BUT  ¦ Autor ¦ Fábrica ERPBR    ¦   Data  ¦ Nov/2025  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Adiciona botões na rotina Despesas de Importação.		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo INTRALOX 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function MA119BUT()

Local aButtons := {}

If FWCodEmp() $("99,U6")
    AAdd(aButtons,{"RPMCPO", {|| A119Check() },"Replicar dados", "Replicar dados"})
Endif    

Return(aButtons)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ A119Check ¦ Autor ¦ Fábrica ERPBR    ¦   Data  ¦ Nov/2025  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Adiciona botões na cotação.          					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo INTRALOX 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function A119Check()

Local nOpcChk := 0
Local bOkChk  := {|| nOpcChk:=1,oDlgChk:End() }
Local bCanChk := {|| nOpcChk:=0,oDlgChk:End() }
Local oDlgChk

Private lCheck1 := .F.
Private lCheck2 := .F.
Private lCheck3 := .F.
Private lCheck4 := .F.
Private lCheck5 := .F.
Private oCheck1, oCheck2, oCheck3, oCheck4, oCheck5

nDlg1 := 001
nDlg2 := 001
nDlg3 := 200
nDlg4 := 390

oDlgChk := MsDialog():New(nDlg1,nDlg2,nDlg3,nDlg4,"Selecione as colunas",,,,,,,,,.T.)

@ 035,005 TO 100,185 LABEL "" OF oDlgChk PIXEL
oCheck1 := TCheckBox():New(045,010,"Sit.Tribut."  ,{|u|IIf(PCount()>0,lCheck1:=u,lCheck1)},oDlgChk,100,210,,,,,,,,.T.,,,)
oCheck2 := TCheckBox():New(055,010,"Aliq. ICMS"   ,{|u|IIf(PCount()>0,lCheck2:=u,lCheck2)},oDlgChk,100,210,,,,,,,,.T.,,,)
oCheck3 := TCheckBox():New(065,010,"Aliq. IPI"    ,{|u|IIf(PCount()>0,lCheck3:=u,lCheck3)},oDlgChk,100,210,,,,,,,,.T.,,,)
oCheck4 := TCheckBox():New(075,010,"C Contabil"   ,{|u|IIf(PCount()>0,lCheck4:=u,lCheck4)},oDlgChk,100,210,,,,,,,,.T.,,,)
oCheck5 := TCheckBox():New(085,010,"Centro Custo" ,{|u|IIf(PCount()>0,lCheck5:=u,lCheck5)},oDlgChk,100,210,,,,,,,,.T.,,,)

oDlgChk:Activate(,,,.T.,{|| _VldCheck() },,{|| EnchoiceBar(oDlgChk,bOkChk,bCanChk) } )

If nOpcChk == 1
    FwMsgRun(, { || A119Replica(lCheck1, lCheck2, lCheck3, lCheck4, lCheck5) },,"Replicando dados... aguarde")
Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ _VldCheck   ¦ Autor ¦ Fábrica ERPBR  ¦   Data  ¦ Nov/2025  ¦¦¦
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

If !lCheck1 .And. !lCheck2 .And. !lCheck3 .And. !lCheck4 .And. !lCheck5
    MsgAlert("Nenhuma opção selecionada.")
    lRetChk := .F.
Endif

Return(lRetChk)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ A119Replica ¦ Autor ¦ Fábrica ERPBR  ¦   Data  ¦ Nov/2025  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Replica dados no aCols.                					  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo INTRALOX 										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function A119Replica(lCheck1, lCheck2, lCheck3, lCheck4, lCheck5)

Local aArea   := GetArea()
Local nPosSit := aScan(aHeader,{|x|Alltrim(x[2])=="D1_CLASFIS"})
Local nPosIcm := aScan(aHeader,{|x|Alltrim(x[2])=="D1_PICM"})
Local nPosIpi := aScan(aHeader,{|x|Alltrim(x[2])=="D1_IPI"})
Local nPosCta := aScan(aHeader,{|x|Alltrim(x[2])=="D1_CONTA"})
Local nPosCus := aScan(aHeader,{|x|Alltrim(x[2])=="D1_CC"})
Local _BkpN := N
Local _x

zCodSit := aCols[1][nPosSit]
zAlqIcm := aCols[1][nPosIcm]
zAlqIpi := aCols[1][nPosIpi]
zContaC := aCols[1][nPosCta]
zCCusto := aCols[1][nPosCus]

For _x := 1 to Len(aCols)
    N := _x
    If !aCols[_x][Len(aHeader)+1]
        
        If lCheck1
            aCols[_x][nPosSit] := zCodSit
            MaFisRef("IT_CLASFIS","MT100",zCodSit)
        Endif

        If lCheck2
            aCols[_x][nPosIcm] := zAlqIcm
            MaFisRef("IT_ALIQICM","MT100",zAlqIcm)
        Endif
        
        If lCheck3
            aCols[_x][nPosIpi] := zAlqIpi
            MaFisRef("IT_ALIQIPI","MT100",zAlqIpi)
        Endif

        If lCheck4
            aCols[_x][nPosCta] := zContaC
        Endif

        If lCheck5
            aCols[_x][nPosCus] := zCCusto
        Endif

        Eval(bRefresh)

    Endif
Next _x

N:= _BkpN
RestArea(aArea)

Return

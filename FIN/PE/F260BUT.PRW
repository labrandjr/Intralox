#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ F260BUT   ¦ Autor ¦ Fábrica ERP.BR   ¦  Data  ¦  Abr-2024  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Novo botão conciliação DDA.                          	  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AFIP   										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function F260BUT()

Local aArea := GetArea()
Local aRotX := PARAMIXB

AAdd(aRotX,{"Reavaliar Fornecedor","U_AF260RE()", 0, 5})

RestArea(aArea)

Return(aRotX)

User Function AF260RE()

Local aArea     := GetArea()
Local cAliasFig := GetNextAlias()

If !MsgYesNo("Confirma reavaliação dos fornecedores ? ")
    Return
Endif

If Select(cAliasFig) > 0 ; (cAliasFig)->(DbCloseArea()) ; Endif

BeginSQL Alias cAliasFig
    SELECT 
        FIG.R_E_C_N_O_ AS RECFIG
    FROM
        %Table:FIG% FIG
    WHERE
        FIG.%NotDel%
        AND FIG_CONCIL = "2"
        //AND FIG_CNPJ = // "30280358000186" //"33040635000171" // "00904728" VYTTRA
EndSql

Begin Sequence

    DbSelectArea(cAliasFig)
    If !(cAliasFig)->(Eof())
        FwMsgRun(, { || ProcReavaliacao(cAliasFig) },,"Processando reavaliação dos fornecedores.")
    Else
        MsgAlert("Sem dados para o processamento.")
    Endif

End Sequence

RestArea(aArea)

Return

Static Function ProcReavaliacao(cAliasFig)

Local nTotReg := 0

While !(cAliasFig)->(Eof())

    DbSelectArea(cAliasFig)
    FIG->(DbGoto( (cAliasFig)->RECFIG ))

    cBaseCnpj := Substr(FIG->FIG_CNPJ,1,8)
    cCodsForn := ""
    cValorFig := AllTrim(STR(FIG->FIG_VALOR))

    cAliasFor := GetNextAlias()
    If Select(cAliasFor) > 0 ; (cAliasFor)->(DbCloseArea()) ; Endif

    BeginSQL Alias cAliasFor
        SELECT 
            A2_COD AS CODFOR,
            A2_LOJA AS LOJFOR
        FROM
            %Table:SA2% SA2
        WHERE
            SA2.%NotDel%
            AND SUBSTRING(A2_CGC,1,8) = %Exp:cBaseCnpj%
    EndSql

    Begin Sequence
        DbSelectArea(cAliasFor)
        (cAliasFor)->(DbGotop())
        While !(cAliasFor)->(Eof())
            cCodsForn += IIf(!Empty(cCodsForn),";","") + AllTrim((cAliasFor)->(CODFOR+LOJFOR))
            DbSelectArea(cAliasFor)
            (cAliasFor)->(DbSkip())
        Enddo
        (cAliasFor)->(DbCloseArea())
    End Sequence

    If !Empty(cCodsForn)

        cWhereFor := "%E2_FORNECE+E2_LOJA IN "+FormatIn(cCodsForn,";")+" AND E2_SALDO > 0 AND E2_NUMBOR = ' '%"

        cAliasPag := GetNextAlias()
        If Select(cAliasPag) > 0 ; (cAliasPag)->(DbCloseArea()) ; Endif

        BeginSQL Alias cAliasPag
            SELECT 
                E2_FORNECE AS CODFOR,
                E2_LOJA AS LOJFOR
            FROM
                %Table:SE2% SE2
            WHERE
                SE2.%NotDel%
                AND %Exp:cWhereFor%
                AND E2_VALOR = %Exp:cValorFig%
        EndSql

        Begin Sequence
            DbSelectArea(cAliasPag)
            (cAliasPag)->(DbGotop())
            If !(cAliasPag)->(Eof())
                If AllTrim(FIG->FIG_FORNEC) <> AllTrim((cAliasPag)->CODFOR)
                    nTotReg += 1
                Endif
                RecLock("FIG",.F.)
                FIG->FIG_FORNEC := (cAliasPag)->CODFOR
                FIG->FIG_LOJA   := (cAliasPag)->LOJFOR
                FIG->FIG_NOMFOR := Posicione("SA2",1,xFilial("SA2")+(cAliasPag)->(CODFOR+LOJFOR),"A2_NREDUZ")
                MsUnLock()
            Endif
            (cAliasPag)->(DbCloseArea())
        End Sequence

    Endif

    DbSelectArea(cAliasFig)
    (cAliasFig)->(DbSkip())
Enddo
(cAliasFig)->(DbCloseArea())

If nTotReg > 0
    MsgInfo("Códigos de Fornecedores substituídos: "+AllTrim(STR(nTotReg)))
Else
    MsgInfo("Códigos de Fornecedores não localizados para substituição.")
Endif

Return

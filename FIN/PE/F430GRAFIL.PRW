#include "Protheus.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ F430GRAFIL ¦ Autor ¦ Fábrica ERPBR   ¦   Data  ¦ Out/2023  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Ponto de Entrada para alterar a filial no DDA.             ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo AFIP    										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function F430GRAFIL()

Local cFilOrig := PARAMIXB // Filial referente ao CNPJ (SM0->M0_CGC) do Header do arquivo

RecLock("FIG",.F.)
FIG->FIG_FILIAL := xFilial("FIG",cFilOrig)
FIG->FIG_FORPAG := IIf(Substr(FIG->FIG_CODBAR,1,3)==Substr(SEE->EE_CODIGO,1,3),"30","31") // Quando for BB testar com o parâmetro SX1 (mv_par05)
FIG->(MsUnlock())
 
Return

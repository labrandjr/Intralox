#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "tbicode.ch"
#include "xmlxfun.ch"
#include "apwebsrv.ch"

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ CHAM001  ¦ Autor ¦ Fabrica ERPBR    ¦ Data  ¦  25/04/2020  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Registro de Chamados.									  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo para Registro de Chamados.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function CHAM001()

Local nX
Local aCores := {}
Local cTabSx2 := "SX2"+cEmpAnt+"0"

Private cUsrConst := AllTrim(GetMv("MV_ZUSRPRT"))
Private lChamHblt := GetMv("MV_ZCHAMAD")

Private cCadastro := "Registro de Chamados"

Private aRotina := {{"Pesquisar"  , "AxPesqui"    , 0 , 1 },;
            	    {"Visualizar" , "U_CHM001V()" , 0 , 2 },;
            	    {"Abrir"      , "U_CHM001A()" , 0 , 3 },;
            	    {"Anexos"     , "MsDocument"  , 0 , 4 , 0 , Nil },;
            	    {"Add Cópia"  , "U_CHM001C()" , 0 , 5 },;
            	    {"Interagir"  , "U_CHM001I()" , 0 , 6 },;
            	    {"Reabrir"    , "U_CHM001R()" , 0 , 7 },;
            	    {"Legenda"    , "U_CHM001L()" , 0 , 1 , 0 , .F.}}

Private cFiltro := "ZC1_STATUS <> ' '"

If !( __cUserId $(cUsrConst) )
	cFiltro := " ZC1_CODUSU == '"+__cUserId+"' "
Else
	AAdd(aRotina, {"Encerrar" , "U_CHM001E()" , 0 , 8 } )
	AAdd(aRotina, {"Ticket"   , "U_CHM001T()" , 0 , 9 } )
	AAdd(aRotina, {"Email"    , "U_CHM001M()" , 0 , 9 } )
	AAdd(aRotina, {"S.L.A"    , "U_CHM001S()" , 0 , 9 } )
	AAdd(aRotina, {"Horas"    , "U_CHM001H()" , 0 , 9 } )
Endif

aCores := {{"ZC1_STATUS == 'A'", "GREEN" , "Aberto" },;
		   {"ZC1_STATUS == 'S'", "BLUE"  , "Pendente Solicitante" },;
		   {"ZC1_STATUS == 'C'", "YELLOW", "Pendente Consultor" },;
		   {"ZC1_STATUS == 'E'", "RED"   , "Encerrado" }}

If !lChamHblt
	MsgAlert("Processo de chamados desabilitado. Contate o Administrador.")
	Return
Endif

If AllTrim(SM0->M0_NOME) == "Grupo Eurofins"
	If DtoS(Date()) > "20260331"
		MsgAlert("A liberação para uso expirou. Solicite a renovação para o proprietário.")
		Return
	Endif
Endif

DbSelectArea("FI0")
DbSelectArea("FI1")

cQuery := " SELECT X2_UNICO "
cQuery += " FROM "+cTabSx2
cQuery += " WHERE X2_CHAVE = 'ZC1' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"SQLX2", .F., .T.)

DbSelectArea("SQLX2")
If !Eof()
	If Empty(SQLX2->X2_UNICO)
		cQuery := " UPDATE "+cTabSx2+" SET X2_UNICO = 'ZC1_FILIAL+ZC1_NUM' WHERE X2_CHAVE = 'ZC1' AND D_E_L_E_T_ <> '*' "
		TcSqlExec(cQuery)
	Endif
Endif
SQLX2->(DbCloseArea())

oMBrowse := FWMBrowse():New()
oMBrowse:SetAlias( "ZC1" )			
oMBrowse:SetDescription( cCadastro )

oMBrowse:AddFilter( "Filtrando registros...", cFiltro, .T., .T., "ZC1", , , "ZC1_FILENT" )		 
oMBrowse:ExecuteFilter()

For nX := 1 to Len(aCores)
	oMBrowse:AddLegend( aCores[nX][1], aCores[nX][2], aCores[nX][3] )
Next nX

oMBrowse:SetTotalDefault("ZC1_FILIAL","COUNT","Total de Registros")		
oMBrowse:Activate()

DbSelectArea("ZC1")
DbSetOrder(1)
DbClearFilter()
		
Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ CHM001V  ¦ Autor ¦ Fabrica ERPBR    ¦ Data  ¦  25/04/2020  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Abertura de Chamado.										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo para Registro de Chamados.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function CHM001V()

Local lCabec := .F.
Local lCopia := .F.
Local lInter := .F.
Local lVisua := .T.

U_CHM001X(lCabec,lCopia,lInter,lVisua)

Return                

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ CHM001A  ¦ Autor ¦ Fabrica ERPBR    ¦ Data  ¦  25/04/2020  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Abertura de Chamado.										  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo para Registro de Chamados.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function CHM001A()

Local lCabec := .T.
Local lCopia := .T.
Local lInter := .F.
Local lVisua := .F.
Local uEmail := UsrRetMail(__cUserId)

If Empty(uEmail)
	MsgAlert("Usuário sem e-mail cadastrado. Contate o Administrador.")
	Return
Endif

U_CHM001X(lCabec,lCopia,lInter,lVisua)

Return                

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ CHM001C  ¦ Autor ¦ Fabrica ERPBR    ¦ Data  ¦  25/04/2020  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Adiciona usuários em cópia.								  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo para Registro de Chamados.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function CHM001C()

Local lCabec := .F.
Local lCopia := .T.
Local lInter := .F.
Local lVisua := .F.

If ZC1->ZC1_STATUS == "E"
	MsgAlert("Chamado encerrado.")
	Return
Endif

U_CHM001X(lCabec,lCopia,lInter,lVisua)

Return                

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ CHM001I  ¦ Autor ¦ Fabrica ERPBR    ¦ Data  ¦  25/04/2020  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Interações no chamado.									  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo para Registro de Chamados.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function CHM001I()

Local lCabec := .F.
Local lCopia := .F.
Local lInter := .T.
Local lVisua := .F.

If ZC1->ZC1_STATUS == "E"
	MsgAlert("Chamado encerrado.")
	Return
Endif

U_CHM001X(lCabec,lCopia,lInter,lVisua)

Return                

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ CHM001E  ¦ Autor ¦ Fabrica ERPBR    ¦ Data  ¦  25/04/2020  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Encerramento do chamado.									  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo para Registro de Chamados.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function CHM001E()

Local lCabec := .F.
Local lCopia := .F.
Local lInter := .F.
Local lVisua := .F.

If ZC1->ZC1_STATUS == "E"
	MsgAlert("Chamado encerrado.")
	Return
Endif

If !MsgYesNo("Confirma encerramento do chamado ?")
	Return
Endif

RecLock("ZC1",.F.)
ZC1->ZC1_STATUS := "E"
MsUnLock()

RecLock("ZC3",.T.)
ZC3->ZC3_FILIAL := xFilial("ZC3")
ZC3->ZC3_NUM    := ZC1->ZC1_NUM
ZC3->ZC3_CODUSU := __cUserId
ZC3->ZC3_NOMUSU := cUserName
ZC3->ZC3_DATA   := Date()
ZC3->ZC3_HORA   := Substr(Time(),1,5)
ZC3->ZC3_DESCRI := "Chamado encerrado"
MsUnLock()

u_MailCham(lCabec,lCopia,lInter,lVisua)

Return                

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ CHM001R  ¦ Autor ¦ Fabrica ERPBR    ¦ Data  ¦  25/04/2020  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Reabertura do chamado.									  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo para Registro de Chamados.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function CHM001R()

Local lCabec := .F.
Local lCopia := .F.
Local lInter := .F.
Local lVisua := .F.

If ZC1->ZC1_STATUS <> "E"
	MsgAlert("O chamado não está encerrado.")
	Return
Endif

If !MsgYesNo("Confirma reabertura do chamado ?")
	Return
Endif

RecLock("ZC1",.F.)
ZC1->ZC1_STATUS := "S"
MsUnLock()

RecLock("ZC3",.T.)
ZC3->ZC3_FILIAL := xFilial("ZC3")
ZC3->ZC3_NUM    := ZC1->ZC1_NUM
ZC3->ZC3_CODUSU := __cUserId
ZC3->ZC3_NOMUSU := cUserName
ZC3->ZC3_DATA   := Date()
ZC3->ZC3_HORA   := Substr(Time(),1,5)
ZC3->ZC3_DESCRI := "Chamado reaberto"
MsUnLock()

u_MailCham(lCabec,lCopia,lInter,lVisua)

Return                

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ CHM001M  ¦ Autor ¦ Fabrica ERPBR    ¦ Data  ¦  25/04/2020  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Renvia email do chamado.									  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo para Registro de Chamados.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function CHM001M()

Local lCabec := .T.
Local lCopia := .T.
Local lInter := .T.
Local lVisua := .T.

If !MsgYesNo("Confirma reenvio do email do chamado ?")
	Return
Endif

u_MailCham(lCabec,lCopia,lInter,lVisua)

Return                

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ CHM001L  ¦ Autor ¦ Fabrica ERPBR    ¦ Data  ¦  25/04/2020  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Legenda.													  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo para Registro de Chamados.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function CHM001L()

Local aCores := {}

aCores := {{"ENABLE"    , "Em aberto"},;
		   {"BR_AZUL"   , "Pendente Solicitante"},;
		   {"BR_AMARELO", "Pendente Consultor"},;
		   {"DISABLE"   , "Encerrado"}}

BrwLegenda(cCadastro,"Legenda",aCores)

Return                

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ CHM001T  ¦ Autor ¦ Fabrica ERPBR    ¦ Data  ¦  25/04/2020  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Associa Ticket ao chamado.								  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo para Registro de Chamados.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function CHM001T()

Local aArea   := GetArea()
Local nOpcTic := 0
Local bOkTic  := {|| nOpcTic:=1,oDlgTic:End() }
Local bCanTic := {|| nOpcTic:=0,oDlgTic:End() }
Local cTicket := ZC1->ZC1_TICKET
Local oFnt2   := TFont():New("Tahoma",,12,,.T.)
Local oDlgTic,oTic

nDlg1 := 001
nDlg2 := 001
nDlg3 := 150
nDlg4 := 376
nLinI := 047

DEFINE MSDIALOG oDlgTic FROM nDlg1,nDlg2 TO nDlg3,nDlg4 TITLE "Ticket Totvs" OF oDlgTic PIXEL

oNumTic:= TSay():New(nLinI,030,{||""},oDlgTic,,oFnt2,,,,.T.,,,150,020)
oNumTic:SetText("Ticket No.")
oNumTic:CtrlRefresh()

@ nLinI-2,060 MSGET oTic VAR cTicket SIZE 070,010 OF oDlgTic PIXEL PICTURE "@!" VALID !Empty(cTicket)

ACTIVATE MSDIALOG oDlgTic ON INIT EnchoiceBar(oDlgTic,bOkTic,bCanTic) CENTERED

If nOpcTic == 1
	If MsgYesNo("Confirma associação do Ticket ao chamado ?")
		RecLock("ZC1",.F.)
		ZC1->ZC1_TICKET := cTicket	
		MsUnLock()
	Endif
Endif

RestArea(aArea)

Return                

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ CHM001S  ¦ Autor ¦ Fabrica ERPBR    ¦ Data  ¦  25/04/2020  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Registra SLA no chamado.									  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo para Registro de Chamados.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function CHM001S()

Local aArea   := GetArea()
Local nOpcSla := 0
Local bOkSla  := {|| nOpcSla:=1,oDlgSla:End() }
Local bCanSla := {|| nOpcSla:=0,oDlgSla:End() }
Local cSla    := ZC1->ZC1_SLA
Local oFnt2   := TFont():New("Tahoma",,12,,.T.)
Local oDlgSla,oSla

nDlg1 := 001
nDlg2 := 001
nDlg3 := 150
nDlg4 := 376
nLinI := 047

DEFINE MSDIALOG oDlgSla FROM nDlg1,nDlg2 TO nDlg3,nDlg4 TITLE "Service Level Agreement" OF oDlgSla PIXEL

oNumSla:= TSay():New(nLinI,030,{||""},oDlgSla,,oFnt2,,,,.T.,,,150,020)
oNumSla:SetText("S.L.A.")
oNumSla:CtrlRefresh()

@ nLinI-2,060 MSGET oSla VAR cSla SIZE 070,010 OF oDlgSla PIXEL PICTURE "@R 99:99" VALID !Empty(cSla)

ACTIVATE MSDIALOG oDlgSla ON INIT EnchoiceBar(oDlgSla,bOkSla,bCanSla) CENTERED

If nOpcSla == 1
	If MsgYesNo("Confirma associação do S.L.A. ao chamado ?")
		RecLock("ZC1",.F.)
		ZC1->ZC1_SLA := cSla	
		MsUnLock()
	Endif
Endif

RestArea(aArea)

Return                

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ CHM001H  ¦ Autor ¦ Fabrica ERPBR    ¦ Data  ¦  25/04/2020  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descriçäo ¦ Registra as horas utilizadas no atendimento do chamado.	  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Uso       ¦ Exclusivo para Registro de Chamados.						  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function CHM001H()

Local aArea   := GetArea()
Local nOpcHrs := 0
Local bOkHrs  := {|| nOpcHrs:=1,oDlgHrs:End() }
Local bCanHrs := {|| nOpcHrs:=0,oDlgHrs:End() }
Local cHrs    := ZC1->ZC1_HRS
Local oFnt2   := TFont():New("Tahoma",,12,,.T.)
Local oDlgHrs,oHrs

nDlg1 := 001
nDlg2 := 001
nDlg3 := 150
nDlg4 := 376
nLinI := 047

DEFINE MSDIALOG oDlgHrs FROM nDlg1,nDlg2 TO nDlg3,nDlg4 TITLE "Horas do Atendimento" OF oDlgHrs PIXEL

oNumHrs:= TSay():New(nLinI,030,{||""},oDlgHrs,,oFnt2,,,,.T.,,,150,020)
oNumHrs:SetText("Horas")
oNumHrs:CtrlRefresh()

@ nLinI-2,060 MSGET oHrs VAR cHrs SIZE 070,010 OF oDlgHrs PIXEL PICTURE "@R 99:99" VALID !Empty(cHrs)

ACTIVATE MSDIALOG oDlgHrs ON INIT EnchoiceBar(oDlgHrs,bOkHrs,bCanHrs) CENTERED

If nOpcHrs == 1
	If MsgYesNo("Confirma associação das horas ao chamado ?")
		RecLock("ZC1",.F.)
		ZC1->ZC1_HRS := cHrs
		MsUnLock()
	Endif
Endif

RestArea(aArea)

Return 

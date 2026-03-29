#Include "protheus.ch"

User Function PE01NFESEFAZ()

Local aArea      := {}
Local cNota      := ""
Local cSerie     := ""
Local cEntSai    := ""
Local cPedido    := ""
Local cPedCli    := ""
Local cSeek		 := ""

Local nI         := 0
Local aRet	     := {}
Local aProd	     := ParamIXB[01]
Local cMensCli   := ParamIXB[02]
Local cMensFis   := ParamIXB[03]
Local aDest	     := ParamIXB[04]
Local aNota      := ParamIXB[05]
Local aInfoItem  := ParamIXB[06]
Local aDupl	     := ParamIXB[07]
Local aTransp    := ParamIXB[08]
Local aEntrega   := ParamIXB[09]
Local aRetirada  := ParamIXB[10]
Local aVeiculo   := ParamIXB[11]
Local aReboque	 := ParamIXB[12]
Local aNfVincRur := ParamIXB[13] 
Local aEspVol    := ParamIXB[14]
Local aNfVinc    := ParamIXB[15]
Local aDetPag    := ParamIXB[16]
Local aObsCont	 := ParamIXB[17]
Local aProcRef   := ParamIXB[18]
Local aMed	     := ParamIXB[19]
Local aLote      := ParamIXB[20]

// HLB ?????????????????????????????????????????????????????????????????????????????????????????????
Local aPedCom    := {} // ParamIXB[21] // CAS - 05/07/2021 NT2020.0006 - Ajustado índice do ParamIXB
Local aExp       := {} // ParamIXB[22] // CAS - 05/07/2021 NT2020.0006 - Ajustado índice do ParamIXB
Local aTotal     := {} // ParamIXB[23] // CAS - 05/07/2021 NT2020.0006 - Ajustado índice do ParamIXB
Local aCst		 := {} // ParamIxb[24] // CAS - 05/07/2021 NT2020.0006 - Ajustado índice do ParamIXB
Local aIcms		 := {} // ParamIxb[25] // CAS - 05/07/2021 NT2020.0006 - Ajustado índice do ParamIXB 	
Local aIpi		 := {} // ParamIxb[26] // CAS - 05/07/2021 NT2020.0006 - Ajustado índice do ParamIXB
Local aICMSST	 := {} // ParamIxb[27] // CAS - 05/07/2021 NT2020.0006 - Ajustado índice do ParamIXB
Local aPIS		 := {} // ParamIxb[28] // CAS - 05/07/2021 NT2020.0006 - Ajustado índice do ParamIXB
Local aCOFINS	 := {} // ParamIxb[29] // CAS - 05/07/2021 NT2020.0006 - Ajustado índice do ParamIXB
Local aCOFINSST	 := {} // ParamIxb[30] // CAS - 05/07/2021 NT2020.0006 - Ajustado índice do ParamIXB
Local aISSQN	 := {} // ParamIxb[31] // CAS - 05/07/2021 NT2020.0006 - Ajustado índice do ParamIXB
Local aAdi		 := {} // ParamIxb[32] // CAS - 05/07/2021 NT2020.0006 - Ajustado índice do ParamIXB
Local aICMUFDest := {} // ParamIxb[33] // CAS - 05/07/2021 NT2020.0006 - Ajustado índice do ParamIXB
Local aIPIDevol	 := {} // ParamIxb[34] // CAS - 05/07/2021 NT2020.0006 - Ajustado índice do ParamIXB
Local aPisAlqZ	 := {} // ParamIxb[35] // CAS - 05/07/2021 NT2020.0006 - Ajustado índice do ParamIXB
Local aCofAlqZ	 := {} // ParamIxb[36] // CAS - 05/07/2021 NT2020.0006 - Ajustado índice do ParamIXB
Local aCsosn	 := {} // ParamIxb[37] // CAS - 05/07/2021 NT2020.0006 - Ajustado índice do ParamIXB
// HLB ?????????????????????????????????????????????????????????????????????????????????????????????

cNota  := aNota[2]
cSerie := aNota[1]

If AllTrim(aNota[4]) == "1"
	cEntSai := "S"
Else
	cEntSai := "E"
EndIf

For nI := 1 To Len(aProd)
	If AllTrim(aProd[nI][23]) $ "10/60/70"
		If !Empty(cMensCli)
			cMensCli += " "				
		EndIf
		If aDest[9]== "SP"
			cMensCli += "O destinatario devera, com relacao as operacoes com mercadorias ou prestacoes de servicos recebidas com imposto retido, escriturar o documento fiscal nos termos do artigo 278 do RICMS."
		EndIf
	EndIf	 
	Exit
Next nI

If cEntSai == "E"

	aArea := SD1->(GetArea())        

	For nI := 1 To Len(aProd)
		
		If !(SF1->F1_TIPO) $ "DB"
			cSeek := xFilial("SD1") + cNota + cSerie + SA2->A2_COD + SA2->A2_LOJA + aProd[nI][2] + aInfoItem[nI][4] 
		Else
			cSeek := xFilial("SD1") + cNota + cSerie + SF1->F1_FORNECE + SF1->F1_LOJA + aProd[nI][2] + aInfoItem[nI][4] 
		EndIf
		
		SD1->(dbSetOrder(1))
		If SD1->(dbSeek(cSeek))
			If SD1->(FieldPos("D1_OBS")) > 0 .And. !Empty(SD1->D1_OBS)
				If !(AllTrim(SD1->D1_OBS) $ AllTrim(cMensCli))
					If !Empty(cMensCli)
						cMensCli += " "
					EndIf
					cMensCli += AllTrim(SD1->D1_OBS)
				EndIf
			EndIf
		EndIf
	Next nI
		
	RestArea(aArea)
	
EndIf

If cEntSai == "S"

	aArea := SC6->(GetArea())
	
	aPedCom := {}
	
	For nI := 1 To Len(aProd)
		SC6->(dbSetOrder(1))
		If SC6->(dbSeek(xFilial("SC6") + aInfoItem[nI][1] + aInfoItem[nI][2])) 
		
			If !Empty(SC6->C6_PEDCLI)
				If SC6->(FieldPos("C6_P_ITCLI")) > 0
					aAdd(aPedCom , {SC6->C6_PEDCLI,SC6->C6_P_ITCLI})
				Else
					aAdd(aPedCom , {SC6->C6_PEDCLI,""})
				EndIf
			Else
				aAdd(aPedCom , {})
			EndIf
			
			If !Empty(SC6->C6_DESCR01)
				aProd[nI][4]  := Substr(SC6->C6_DESCR01,1,120)
				aProd[nI][25] := Substr(SC6->C6_DESCR01,120,Len(SC6->C6_DESCR01))
			EndIf
			
			If !Empty(SC6->C6_PEDCLI)
				If !(AllTrim(SC6->C6_PEDCLI) $ cPedCli) 	
					If !Empty(cPedCli)
						cPedCli += " / "
					EndIf			
					cPedCli += AllTrim(SC6->C6_PEDCLI)	
				EndIf
			EndIf					
					
			If !(AllTrim(aInfoItem[nI][1]) $ cPedido)
				If !Empty(cPedido)
					cPedido += " / "
				EndIf			
				cPedido += AllTrim(aInfoItem[nI][1])
			EndIf
								
		EndIf
	Next nI

	If !Empty(cMensCli)
		cMensCli += " "
	EndIf
	cMensCli += "O comprador declara concordar que o presente pedido de compra esta sujeito as - CONDICOES GERAIS DE VENDA DA INTRALOX BRASIL LTDA - devidamente registrada sob o no.6953440, no 3o. Cart.Reg.Titulos e Doc.,a Rua XV de Novembro,80-Sao Paulo/SP."
	
	If !Empty(cPedCli)
		cMensCli += " Pedido: " + AllTrim(cPedCli)
	EndIf
	
	If !Empty(cPedido)
		cMensCli += " Nosso Pedido: " + AllTrim(cPedido)
	EndIf
	
	RestArea(aArea)	

EndIf	
	
aAdd(aRet,aProd) 	  // [01]
aAdd(aRet,cMensCli)	  // [02]
aAdd(aRet,cMensFis)	  // [03]
aAdd(aRet,aDest)	  // [04]
aAdd(aRet,aNota)	  // [05]
aAdd(aRet,aInfoItem)  // [06]
aAdd(aRet,aDupl)	  // [07]
aAdd(aRet,aTransp)	  // [08]
aAdd(aRet,aEntrega)	  // [09]
aAdd(aRet,aRetirada)  // [10]
aAdd(aRet,aVeiculo)	  // [11]
aAdd(aRet,aReboque)	  // [12]
aAdd(aRet,aNfVincRur) // [13]
aAdd(aRet,aEspVol)	  // [14]
aAdd(aRet,aNfVinc)	  // [15]
aAdd(aRet,aDetPag)	  // [16]
aAdd(aRet,aObsCont)	  // [17]
aAdd(aRet,aProcRef)   // [18]
aAdd(aRet,aMed)		  // [19]
aAdd(aRet,aLote)	  // [20]

// HLB ??????????????????????
aAdd(aRet,aPedCom)	  // [21]
aAdd(aRet,aExp)		  // [22]
aAdd(aRet,aTotal)	  // [23]
aAdd(aRet,aCst)		  // [24]
aAdd(aRet,aIcms)	  // [25]
aAdd(aRet,aIpi)		  // [26]
aAdd(aRet,aICMSST)	  // [27]
aAdd(aRet,aPIS)		  // [28]
aAdd(aRet,aCOFINS)	  // [29]
aAdd(aRet,aCOFINSST)  // [30]
aAdd(aRet,aISSQN)	  // [31]
aAdd(aRet,aAdi)		  // [32]
aAdd(aRet,aICMUFDest) // [33]
aAdd(aRet,aIPIDevol)  // [34]
aAdd(aRet,aPisAlqZ)	  // [35]
aAdd(aRet,aCofAlqZ)	  // [36]
aAdd(aRet,aCsosn)	  // [37]
// HLB ??????????????????????

Return(aRet)

SELECT customerid
      ,dt
      ,usecase2
      ,ebelia_tag
      ,partner_wallet
      ,sum(customer_wallet_RM) as customer_wallet_RM
      ,sum(partner_wallet_RM) as partner_wallet_RM
      ,sum(gtv) as gtv
      ,sum(
                        case
                            when usecase2 = 'ONLINE-OTHERS'  then GTV * 0.0058
                            when usecase2 = 'TOPUP & DATA PACKAGE' then GTV * 0.0372
                            when usecase2 = 'BILL' then GTV * 0.0056
                            when usecase2 = 'TRANSIT/TRANSPORT' then GTV * 0.0048
                            when usecase2 = 'ONLINE' then GTV * 0.0023
                            when usecase2 = 'OFFLINE' then GTV * 0.0017
                            when usecase2 = 'VOUCHER' then GTV * 0.0264
                            else GTV * 0.0001
                        end
                    ) as NR
        ,count(*) AS txn_volume FROM (
SELECT
	txn as dt
  ,customerid
	,accountid
	,category
	,v_tm.skucode
  ,partner_wallet
  ,sum(amount1) / 100.0 as customer_wallet_RM
  ,sum(amount2) / 100.0 as partner_wallet_RM
  ,SUM((amount1 + amount2 - COALESCE(deduct_amount,0)- COALESCE(deduct_amount2,0)))/100.0 AS GTV
	,CASE
		WHEN category = 'TRANSFER'
			AND subcategory = 'BANK' THEN 'CASH OUT'
		ELSE subcategory
	END AS subcategory
	,CASE /* 15 - CASE STATEMENT for usecase2 */
	    WHEN v_tm.skucode IN (
		
			-- FSM 
			'HELLOGOLD_SDN_BHD'
			,'EASTSPRINGINVESTMENTS'
			,'EASTSPRING_INVESTMENTS_BERHAD'
			,'MSIG_INSURANCE_(MALAYSIA)_BHD'
			,'PAMB(PWP_AGENCY)'
			,'PAMB-CWP'
			,'PAMB-PRUSERVEPLUS'
			,'PAMB-WEBCORP'
			,'PRUDENTIALBSN'
			,'PRUDENTIALBSN2'
			,'PRUDENTIAL_ASSURANCE_MALAYSIA_BERHAD'
			,'PRUDENTIAL_BSN_TAKAFUL_BERHAD'
			,'PRUDENTIAL_SERVICES_ASIA_SDN_BHD'
			,'PBTB_PAYMENTGATEWAY'
			,'PBTB_TOUCH'
			,'OPUS_ASSET_MANAGEMENT_SDN_BHD'
			,'JOMRUN_SDN._BHD.'
			,'SSDUINNOVATIONS'
			,'ssdu_innovations_sdn_bhd'
			,'LIBERTY_INSURANCE_BERHAD'
			,'MANULIFE_INSURANCE_BERHAD'
			,'AXA_AFFIN_GENERAL_INSURANCE_BERHAD'
			,'RHB_INSURANCE_BHD'
			,'axa_affin_general_insurance_berhad'
			,'ISM_INSURANCE_SERVICES_MALAYSIA_BERHAD'
			,'BERJAYA_SOMPO_INSURANCE_BERHAD'
			,'LONPAC_INSURANCE_BHD'
			,'DEMOACC436_-_BERJAYA_SOMPO_INSURANCE_BERHAD_[TRAVEL]'
			,'BERJAYASOMPOINSURANCE'
			,'ARCHIPELAGO_INSURANCE_LIMITED'
			,'LIBERTY_INSURANCE_BERHAD'
			,'AXA_AFFIN_LIFE_INSURANCE_BERHAD'
			,'HONG_LEONG_ASSURANCE_BERHAD'
		
			-- Entertainment and Games 
			,'SEA_GAMER_MALL'
			,'garena_malaysia_sdn_bhd'
			,'GARENA_MALAYSIA_SDN_BHD'
			,'GARENAMALAYSIA'
			,'garenamalaysia'
			,'CODAPAYMENTS'
			,'ASIA_DIGITAL_PTE_LTD'
			,'UNIPIN'
			,'RazerMS_AATOKIOMARINE'
			,'RazerMS_AATOKIOMARINE_TML0001'
			,'RazerMS_AATOKIOMARINE_TML0002'
			,'RazerMS_AATOKIOMARINE_TML0003'
			,'RazerMS_AATOKIOMARINE_TML0004'
			,'RazerMS_AATOKIOMARINE_TML0005'
			,'RazerMS_AATOKIOMARINE_TML0006'
			,'RazerMS_AATOKIOMARINE_TML0007'
			,'RazerMS_AATOKIOMARINE_TML0008'
			,'RazerMS_AATOKIOMARINE_TML0009'
			,'RazerMS_AATOKIOMARINE_TML0010'
			,'RazerMS_AATOKIOMARINE_TML0011'
			,'RazerMS_AATOKIOMARINE_TML0012'
			,'RazerMS_AATOKIOMARINE_TML0013'
			,'RazerMS_AATOKIOMARINE_TML0015'
			,'RazerMS_AATOKIOMARINE_TML0016'
			,'OFFGAMERS_SDN_BHD'
			,'VUCLIP_MALAYSIA_SDN_BHD'
			,'ASIA_DIGITAL_PTE_LTD'
			,'vuclip_malaysia_sdn_bhd'
			,'offgamers_sdn_bhd'
			,'GO|GAMES'
			,'AXIATA_GAME_HERO'
	    )
	    	OR subcategory = 'INSURANCE'
	    THEN 'ONLINE-OTHERS'
	
		-- Bill payment and telco
	    WHEN v_tm.skucode IN (
			'CELCOM'
			,'CELCOM_MOBILE_SDN_BHD'
			,'CELCOM_ONLINE_SHOP'
			,'DIGI_(COMMEWALLET)'
			,'DIGI_TELECOMMUNICATIONS_SDN_BHD'
			,'DIGI_TELECOMMUNICATION_SDN_BHD'
			,'DIGICCCP-EWALLET'
			,'TUNETALK_MOBILEAPP'
			,'TT_DOTCOM_SDN_BHD'
			,'INDAH_WATER_KONSORTIUM_SD'
			,'INDAH_WATER_KONSORTIUM'
			,'AIR_KELANTAN_SDN_BHD'
			,'MAXIS'
			,'E-PAY_(M)_SDN_BHD'
	    )
			OR subcategory = 'BILL'
	    THEN 'BILL'
	    WHEN subcategory IN (
			'DATA'
			,'TOPUP'
			,'PACKAGE'	
	    )
	    THEN 'TOPUP & DATA PACKAGE'
	
		-- Transit and transport
	    WHEN subcategory = 'TICKET'
			OR subcategory = 'PARKING'
			OR SUBSTRING(subcategory,1,9)='TRANSPORT'
			OR v_tm.skucode IN (
				'BATERIKU.COM'
				,'BATERIKU_(M)_SDN_BHD'
				,'A-BUSEXPRESS(MOBILE)'
				,'SETEL'
				,'FERRYLINE'
				,'MALAYSIA_AIRLINES_BERHAD_(MY_WALLETS)'
			)
	    THEN 'TRANSIT/TRANSPORT'
	
		-- Online (pure online)
		WHEN maid IN (
	        '5e339321b1f01300017432ef' /* MPAY - Online Partner-1 */
	        ,'5e159eac82adbf0001d6b309' /* MOLPAY Sdn Bhd-2 */
	        ,'5e159fa942148e0001700a47' /* MOLPAY Sdn Bhd-4 */
	        ,'5e159f311b6a5300017703b0' /* MOLPAY Sdn Bhd-3 */
	        ,'5e257cc31e4100000117fff0' /* MPAY - Online Partner */
	        ,'5e15a66a82adbf0001d6b7ab' /* [Online] REVENUE SOLUTION SDN BHD-3 */
	        ,'5e15a5ddb5644a00010dfeeb' /* [Online] REVENUE SOLUTION SDN BHD-2 */
	        ,'5e15a55482adbf0001d6b6f7' /* [Online] REVENUE SOLUTION SDN BHD-1 */
	        ,'5e15a477a9c1730001d862e6' /* IPAY88 (M) SDN BHD-9 */
	        ,'5e15a404e573c40001bc179b' /* IPAY88 (M) SDN BHD-8 */
	        ,'5e15a38b82adbf0001d6b5e9' /* IPAY88 (M) SDN BHD-7 */
	        ,'5e15a30742148e0001700c65' /* IPAY88 (M) SDN BHD-6 */
	        ,'5e15a2911b6a53000177057b' /* IPAY88 (M) SDN BHD-5 */
	        ,'5e15a1fe42148e0001700bb7' /* IPAY88 (M) SDN BHD-4 */
	        ,'5e15a18df1e98d0001610961' /* IPAY88 (M) SDN BHD-3 */
	        ,'5e15a0ffa9c1730001d860d1' /* IPAY88 (M) SDN BHD-2 */
	        ,'5e15a0677963e800019ee4b8' /* IPAY88 (M) SDN BHD-1 */
	        ,'5cf08ad4b5618f4208d534b4' /* IPAY88 (M) SDN BHD */
	        ,'5f48cf38b153a800013bdb9d' /* IPAY88 (M) SDN BHD-21 */
	        ,'5f48cfb3d329a40001ca9870' /* IPAY88 (M) SDN BHD-22 */
	        ,'5f1e9bc55186e50001214814' /* IPAY88 (M) SDN BHD-1*/
	        ,'5e159d42b5644a00010dfa02' /* GHL ePayments Sdn Bhd-7 */
	        ,'5e159cc3a9c1730001d85e92' /* GHL ePayments Sdn Bhd-6 */
	        ,'5e159c447963e800019ee258' /* GHL ePayments Sdn Bhd-5 */
	        ,'5e159bc682adbf0001d6b170' /* GHL ePayments Sdn Bhd-4 */
	        ,'5e159b54790e8100017f2051' /* GHL ePayments Sdn Bhd-3 */
	        ,'5e159ab9411ede0001213d99' /* GHL ePayments Sdn Bhd-2 */
	        ,'5e159a0cb5644a00010df823' /* GHL ePayments Sdn Bhd-1 */
	        ,'5cf08ad6b5618f4208d53c86' /* GHL ePayments Sdn Bhd */
	        ,'5e15c87ef397bf0001d3204c' /* ASIAPAY (M) SDN. BHD. (Terminal)-1 */
	        ,'5e15c93aa9c1730001d87957' /* ASIAPAY (M) SDN. BHD. (Terminal)-3 */
	        ,'5e15c9d51401570001c4dbdf' /* MOLPAY Sdn Bhd-7 */
	        ,'5cf08b6fb5618f4208d5a0d6' /* Revenue Solution Sdn. Bhd. */
	        ,'5cf08ad4b5618f4208d534b4' /* IPAY88 (M) SDN BHD */
	        ,'5cf08ad6b5618f4208d53c86' /* GHL ePayments Sdn Bhd */
	        ,'5cf08ae4b5618f4208d551ba' /* Presto Mall Sdn Bhd */
	        ,'5cf08ae4b5618f4208d551ee' /* Celcom Mobile Sdn Bhd */
	        ,'5cf08aecb5618f4208d561c9' /* Apigate Sdn Bhd */
	        ,'5cf08b1fb5618f4208d5789f' /* INFINITY BEE UNIT */
	        ,'5cf08b2db5618f4208d58274' /* iALab Trading */
	        ,'5cf08b6fb5618f4208d5a0d6' /* [Online] REVENUE SOLUTION SDN BHD */
	        ,'5cf08b8fb5618f4208d5a902' /* RED IDEAS SDN BHD */
	        ,'5cf08b09b5618f4208d56ddf' /* FAVE ASIA TECHNOLOGIES SDN BHD */
	        ,'5cf08b31b5618f4208d5866a' /* LEAPFAST TRADING */
	        ,'5cf08b32b5618f4208d587fe' /* Scientific Retail Sdn Bhd */
	        ,'5cf08b33b5618f4208d5897e' /* Presto Mall Sdn Bhd */
	        ,'5cf08b33b5618f4208d5897f' /* [APPTILE]Delivereat Sdn Bhd */
	        ,'5cf08b33b5618f4208d58980' /* City Bee Sdn. Bhd. */
	        ,'5cf08b33b5618f4208d58981' /* [APPTILE]City Bee Sdn. Bhd. */
	        ,'5cf08b37b5618f4208d59429' /* JOCOM MSHOPPING SDN BHD */
	        ,'5cf08b49b5618f4208d59895' /* PAYDIBS SDN BHD (CHECKOUT) */
	        ,'5cf08b83b5618f4208d5a5c1' /* WETIX SDN BHD */
	        ,'5cf08b85b5618f4208d5a632' /* PETBACKER SDN BHD */
	        ,'5cf08baeb5618f4208d5b1a7' /* JMB OF TROPICANA BAY RESIDENCES */
	        ,'5cf08bcbb5618f4208d5bb6d' /* THE COLONY EMPIRE */
	        ,'5cf08bd2b5618f4208d5be77' /* LSCA TRADING SDN BHD */
	        ,'5cf08bd6b5618f4208d5c04a' /* Mayflower Holidays Sdn Bhd */
	        ,'5cf08bdab5618f4208d5c235' /* Ibibo Group Sdn Bhd */
	        ,'5cf08bdbb5618f4208d5c288' /* [APPTILE] FARM TO FORK SDN BHD */
	        ,'5cf08be0b5618f4208d5c501' /* FARM TO FORK SDN BHD */
	        ,'5cf08be4b5618f4208d5c72a' /* ASIAPAY (M) SDN BHD */
	        ,'5cf08be5b5618f4208d5c7c5' /* JACKTRONICS ENTERPRISE */
	        ,'5cf08bf0b5618f4208d5cf4b' /* JOMPARKIR SDN BHD */
	        ,'5cf08bf2b5618f4208d5d0e4' /* ALTERSEAT ENTERPRISE */
	        ,'5cf08bf6b5618f4208d5d48e' /* CITY BEE SDN. BHD. [In-App Tile] */
	        ,'5cf08bf6b5618f4208d5d497' /* MAYFLOWER HOLIDAYS SDN BHD [In-App Tile] */
	        ,'5cf08bf7b5618f4208d5d5d6' /* IBIBO GROUP SDN BHD [In-App Tile] */
	        ,'5cf08bf9b5618f4208d5d8bc' /* Serv Technology Sdn Bhd */
	        ,'5cf08bfcb5618f4208d5dcbd' /* BOUNTIFUL VENTURES SDN BHD */
	        ,'5cf08bfdb5618f4208d5defe' /* WIRELESSSPACE SDN BHD */
	        ,'5cf08bfdb5618f4208d5df91' /* BillPlz Sdn Bhd */
	        ,'5cf08bfeb5618f4208d5e2d7' /* DOROPU SDN BHD */
	        ,'5d0af06ee64e0c000129b125' /* METRO TECH TECHNOLOGIES */
	        ,'5d1c0b27b94bed0001edf19f' /* BDB MAJU ENTERPRISE */
	        ,'5d2d93a9571fd30001ba6939' /* STOREHUB SDN BHD */
	        ,'5d3e62fee5e7c20001647ced' /* CELESSA SOFT CLOTHING */
	        ,'5d5b97cebd30610001e3f987' /* MIAKI & CO LTD [In-App Tile] */
	        ,'5d5ce9b37e7e690001baba57' /* TECHNINIER SDN. BHD. */
	        ,'5d5ce355cdf0e800011a84fe' /* MAIDEASY SDN. BHD. [In-App Tile] */
	        ,'5d9afc112f350600018c99e4' /* SAPHX TECHNOLOGIES SDN BHD */
	        ,'5d00b2a8c481240001713779' /* STRAWBERRY TAGS ENTERPRISE */
	        ,'5d12e4ca5a85c400019927be' /* BOUNTIFUL VENTURES SDN BHD */
	        ,'5d23f63fe340b10001f60b72' /* POPLICIOUS CANDY FACTORY */
	        ,'5d36a6b41c524f0001564685' /* 2C2P SYSTEM (M) SDN BHD */
	        ,'5d43a612254ae6000182b5be' /* GREEN INITIATIVE SDN BHD */
	        ,'5d47c6fd7075d600010d0b0a' /* BUYMALL SERVICES SDN. BHD. */
	        ,'5d78c29455e27000014daa9b' /* EC VENDING MARKETING */
	        ,'5d95aa212739750001602518' /* INFINITE BOUTIQUE */
	        ,'5d312b6c3a45480001447ac8' /* SALAD ATELIER CAFE PLT */
	        ,'5d313fe25f99e700017811fa' /* PICHA SDN BHD */
	        ,'5d537dd4dc1f6800014ef58b' /* K.R.M. Solution Company */
	        ,'5d540faedc1f6800014ff017' /* SSDU INNOVATIONS SDN. BHD. */
	        ,'5d707c6cdfeba3000160e941' /* ATX DISTRIBUTION SDN. BHD. */
	        ,'5d721f1955e270000146b37e' /* THE LORRY ONLINE SDN BHD */
	        ,'5d897a141fa75d0001fb3834' /* SEVENTEEN NETWORK SERVICES SDN BHD */
	        ,'5d931ad4e47e1400013ad5a5' /* PG MALL SDN BHD */
	        ,'5d3699a1b0b0130001c269be' /* NIA RAISA ENTERPRISE */
	        ,'5d7075fba639bc000149192e' /* MY LITTLE CLOSET */
	        ,'5d7859aea639bc000152262a' /* Celcom Mobile Sdn Bhd */
	        ,'5d8071b90cdcdf0001adc0dd' /* ICART MALAYSIA SDN BHD */
	        ,'5d8325b699ca5100010f14c1' /* TECHNINIER SDN. BHD. */
	        ,'5d15856d75b64400010fd5ba' /* Badan Pengurusan Bersama Andana D'Alpinia */
	        ,'5d70704bf6d16500016cfba5' /* SUMMERVEIL APPAREL */
	        ,'5d3135355b6a910001a34eaf' /* NEUPULSE SDN BHD */
	        ,'5d3137063a45480001448b55' /* GREAT BLOOMINGS ENTERPRISE */
	        ,'5d80833898c3be00013c1582' /* NKL 300 MALAYSIA SDN BHD */
	        ,'5da3d5daa1aa7a0001560c86' /* SHIRO TOYS */
	        ,'5da6bcd6a1aa7a000158abfd' /* SUREPLIFY SDN. BHD. */
	        ,'5da6f60826b7c30001d05580' /* ZEPTOLAB SDN. BHD. */
	        ,'5da7c60ae3a6fb000128a6df' /* LITTLE SHOP JY ENTERPRISE */
	        ,'5da92f1f55c0aa0001484354' /* YOUBUY ONLINE SDN BHD */
	        ,'5da9273a828bf90001dcfeeb' /* SABAH CREDIT CORPORATION */
	        ,'5dad533ea406a900018c2a69' /* JOBBIE SDN BHD */
	        ,'5dad2595ce0c5000014ad537' /* RECOMN TECHNOLOGIES SDN BHD */
	        ,'5dad252208846d0001329506' /* RECOMN TECHNOLOGIES SDN BHD */
	        ,'5db2b7dda45c100001745192' /* TAOBAOKAKI PLT */
	        ,'5db93fe0a45c10000179d24b' /* EVR RESOURCES SDN BHD */
	        ,'5dbbffcf3297c80001f8d2d0' /* INTERBASE RESOURCES SDN BHD */
	        ,'5dc0e5541e96450001fe5a24' /* AMAZING DREAM ENTERPRISE */
	        ,'5dccb45c91795900014d27bc' /* MAXWELL FOREST (MALAYSIA) SDN BHD */
	        ,'5dce70a1c80d020001b67038' /* FAITH DRIVEN COFFEE SDN BHD */
	        ,'5ddce201a6061b000159848c' /* PAY DIRECT TECHNOLOGY SDN BHD */
	        ,'5def49fc66d6980001abf884' /* SONICBOOM SOLUTIONS SDN. BHD. */
	        ,'5e0b04fc7815a20001b3c0c0' /* EASYBOOK (M) SDN. BHD. */
	        ,'5e0b08e58e9849000107b4e5' /* EASYBOOK (M) SDN. BHD. */
	        ,'5e0b09a23b150b0001ee5a83' /* EASYBOOK (M) SDN. BHD. */
	        ,'5e0b07327b4f480001d3b2c6' /* EASYBOOK (M) SDN. BHD. */
	        ,'5e0b09397815a20001b3c399' /* EASYBOOK (M) SDN. BHD. */
	        ,'5e1bc463cee698000125d51e' /* BOOKALICIOUS SDN BHD */
	        ,'5e4c84a0975dd00001c63d55' /* ASIAPAY (M) SDN BHD */
	        ,'5e4c8426c323da000109ef13' /* ASIAPAY (M) SDN BHD */
	        ,'5e79d421a46f190001ea4a70' /* DIINEOUT.COM */
	        ,'5e169f0b05b4400001311a1b' /* SITEGIANT SDN BHD */
	        ,'5e782e0da48ecf00011c48a2' /* AXIATA DIGITAL CAPITAL SDN BHD */
	        ,'5e4262de62992d00014650b2' /* 2C2P SYSTEM (M) SDN BHD */
	        ,'5e4650a17ab7120001ee4ab2' /* EASYBOOK (M) SDN. BHD. */
	        ,'5e42638551dc790001afa5e1' /* 2C2P SYSTEM (M) SDN BHD */
	        ,'5e42647207c795000100dcd1' /* 2C2P SYSTEM (M) SDN BHD */
	        ,'5e426407555fb70001527608' /* 2C2P SYSTEM (M) SDN BHD */
	        ,'5e15a55482adbf0001d6b6f7' /* [Online] REVENUE SOLUTION SDN BHD */
	        ,'5e15a5ddb5644a00010dfeeb' /* [Online] REVENUE SOLUTION SDN BHD */
	        ,'5e159a0cb5644a00010df823' /* GHL ePayments Sdn Bhd */
	        ,'5e159ab9411ede0001213d99' /* GHL ePayments Sdn Bhd */
	        ,'5e159d42b5644a00010dfa02' /* GHL ePayments Sdn Bhd */
	        ,'5e15a0677963e800019ee4b8' /* IPAY88 (M) SDN BHD */
	        ,'5e15a0ffa9c1730001d860d1' /* IPAY88 (M) SDN BHD */
	        ,'5e15a1fe42148e0001700bb7' /* IPAY88 (M) SDN BHD */
	        ,'5e159eac82adbf0001d6b309' /* MOLPAY SDN BHD */
	        ,'5e159f311b6a5300017703b0' /* MOLPAY SDN BHD */
	        ,'5e159fa942148e0001700a47' /* MOLPAY SDN BHD */
	        ,'5e257cc31e4100000117fff0' /* ManagePay Services Sdn Bhd */
	        ,'5cf08b33b5618f4208d5897f' /* Delivereat */
	        ,'5cf08bdbb5618f4208d5c288' /* Dahmakan */
	        ,'5e79d421a46f190001ea4a70' /* Diineout */
	        ,'5cf08b33b5618f4208d58980' /* Catch That Bus */
	        ,'5cf08bdab5618f4208d5c235' /* Redbus */
	        ,'5e0b07327b4f480001d3b2c6' /* Easybook (Bus) */
	        ,'5e0b09a23b150b0001ee5a83' /* Easybook (Car Rental) */
	        ,'5e0b09397815a20001b3c399' /* Easybook (Ferry) */
	        ,'5e0b04fc7815a20001b3c0c0' /* Easybook (Online) */
	        ,'5e0b08e58e9849000107b4e5' /* Easybook (Train) */
	        ,'5e4650a17ab7120001ee4ab2' /* Easybook (Flights) */
	        ,'5cf08b33b5618f4208d5897e' /* PrestoMall */
	        ,'5d47c6fd7075d600010d0b0a' /* Buymall */
	        ,'5da92f1f55c0aa0001484354' /* Youbeli */
	        ,'5cf08bf6b5618f4208d5d4d5' /* Tripcarte (iPay88) */
	        ,'5cf08bf6b5618f4208d5d48e' /* Trokka */
	        ,'5cf08bf6b5618f4208d5d497' /* Mayflower */
	        ,'5d397c88b2460c00012759e4' /* Adventoro */
	        ,'5cf08bf9b5618f4208d5d8bc' /* SERV */
	        ,'5da6bcd6a1aa7a000158abfd' /* Sureplify (eGHL) */
	        ,'5dad2595ce0c5000014ad537' /* Recommend.my */
	        ,'5d5ce355cdf0e800011a84fe' /* Maideasy */
	        ,'5eaa88554984c900018015ec' /* iprice */
	        ,'5f44c3c0fdf993000185bd62' /* GHL ePayments Sdn Bhd (McDelivery) */
	        ,'5e85a017f5cc790001af443b' /* IPAY88 (M) SDN BHD-11 */
	        ,'5f1018b34b85af0001e7b782' /* IPAY88 (M) SDN BHD-18 */
	        ,'5f1012c8919fba0001bd658d' /* IPAY88 (M) SDN BHD-17 */
	        ,'5f2bbf6fa0923800011cb9b0' /* IPAY88 (M) SDN BHD-20 */
	        ,'5f6845b7601bfc0001c31c92' /* IPAY88 (M) SDN BHD */
	        ,'5f1818182b43a0000166ab99' /* MOLPAY Sdn Bhd-27 */
	        ,'5f5aebc4e1932400010a5af8' /* Easy Parcel - Direct */
	        ,'5fdfdbbab1c32400018baaaf' -- SNEAKERLAH
	        ,'5f59f3416074500001a65c84' -- SERVAY ONLINE SDN. BHD.-1
	        ,'5da9273a828bf90001dcfeeb' -- SABAH CREDIT CORPORATION
	        ,'5f8ff9ac27956500014d08f5' -- MOREFUN
	        ,'5f3f4bb31b658c0001db8fd9' -- [Online] REVENUE SOLUTION SDN BHD-5
	        ,'6011093675721a0001b483d8' -- EASI IN APP
	        ,'5f50d236de5bc20001797371' /* LAZADA */
	        ,'5f5721978f6eb3000104ce21' -- A la Carte
	        ,'5f6bf85046c25500015273bc' -- [Online] REVENUE SOLUTION SDN BHD
	        ,'5cf08ad6b5618f4208d53e71' -- MOBI ASIA SDN BHD
	        ,'5cf08bf5b5618f4208d5d423' -- MYPOZ PLUS PUCHONG ENTERPRISE
	        ,'602224c2911de623ee9bd8db' -- GAM TONG
	        ,'6035d2d4405588514575f3d3' -- EASI
	        ,'5ea116be61b58a0001d8fb9d' -- ICART MALAYSIA SDN BHD / HAPPY FRESH IN APP
	        ,'5f101042a666ae00014e74eb' -- GHL ePayments Sdn Bhd-13
	        ,'603cbb4bfffc456898fb6ef1' -- A la Carte In App
		)
			OR subcategory IN (
				'ONLINE'
				,'DEEPLINK'
				,'PARTNER-INAPP'
				,'LOYALTY'
			)
	    THEN 'ONLINE'
	
		--Offline and others
	    WHEN subcategory IN (
			'OFFLINE'
			,'PAYMENT_LINK'
	    )
	    THEN 'OFFLINE'
	    WHEN category='DEPOSIT'
			AND subcategory IN (
		        'REWARD'
		        ,'P2P'
		        ,'VOUCHER'
		        ,'PARTNER'
		        ,'CLAIM'
		        ,'IMPREST'
			)
	    THEN NULL
	    ELSE subcategory
	END AS usecase2,
  CASE WHEN ebelia_customerid IS NOT NULL THEN 'e-Belia' ELSE 'Normal' END AS ebelia_tag

FROM (
        (
            SELECT *,
                COALESCE(ABS(amount), 0) AS amount1,
                COALESCE(ABS(customersecondarytransactionusage_amount), 0) AS amount2,
                (datecreated + interval '8 hours') AS txn
            FROM (
                    SELECT *,
                        ROW_NUMBER() OVER(
                            PARTITION BY id
                            ORDER BY __last_sync_ts DESC
                        ) AS R
                    FROM vault.transaction_customer
                )
            WHERE R = 1
                AND category = 'PAYMENT'
                AND STATUS in (
                    'CAPTURED',
                    'PARTIALLY_REFUNDED',
                    'PARTIALLY_VOIDED'
                )
                AND date(datecreated + INTERVAL '8 HOURS') >= '2021-07-01'
        ) v_tc

        LEFT JOIN (
            SELECT
        SUM(COALESCE(ABS(amount),0)) AS deduct_amount
        ,SUM(COALESCE(ABS(customersecondarytransactionusage_amount),0)) AS deduct_amount2
        ,link_transactionid
    FROM (
        SELECT 
            * 
            ,ROW_NUMBER() OVER (PARTITION BY id ORDER BY __last_sync_ts DESC) AS dedup4
        FROM vault.transaction_customer
    )
    WHERE category IN (
        'PARTIAL_REFUND'
        ,'PARTIAL_VOID'
    )
    AND dedup4 = 1
  GROUP BY link_transactionid
        ) v_tc_r ON v_tc.id = v_tc_r.link_transactionid

        LEFT JOIN
        (SELECT DISTINCT accountid AS maid
                        , skucode
                        , correlationid
              FROM
              (
                SELECT accountid
                        , skucode
                        , correlationid
                ,ROW_NUMBER() OVER(
                PARTITION BY id
                ORDER BY __last_sync_ts DESC
                ) AS rn
        FROM vault.transaction_merchant)
        WHERE rn = 1
        ) v_tm ON v_tm.correlationid = v_tc.correlationid 
        INNER JOIN (
            SELECT DISTINCT secondaryaccounts_configurationid,
                secondaryaccounts_displayname AS partner_wallet
            FROM vault.account_customer_secondary
            WHERE secondaryaccounts_configurationid IN (
                    '60decf810d65542bd31008c4',
                    '60f530d69eca217936e34291'
                )
        ) pw ON v_tc.customersecondarytransactionusage_subwalletid = pw.secondaryaccounts_configurationid
    LEFT JOIN (
      SELECT 
        distinct customerid
        , id 
        FROM vault.account_customer) vac
        ON v_tc.accountid =vac.id
        
        LEFT JOIN ( SELECT distinct ebelia_customerid FROM  
                (SELECT
                customerid as ebelia_customerid
                , gender
                , age
                , cdbstatus
                , responsecode
                , datecreated + interval '8 hours' AS claimdate
                , ROW_NUMBER() OVER (PARTITION BY id ORDER BY __last_sync_ts DESC) AS dedup
                FROM  
                ebelia.claim
                )
              WHERE dedup = 1
              AND cdbstatus = 'SUCCESS'
            ) ebelia_
            ON vac.customerid = ebelia_.ebelia_customerid)
GROUP BY dt
  , customerid
  , category
  , subcategory
  , usecase2
  , accountid
  , v_tm.skucode
  , ebelia_tag
  , partner_wallet
)
GROUP BY dt
  , customerid
  , usecase2
  , ebelia_tag
  , partner_wallet
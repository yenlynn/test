SELECT DISTINCT --vac_customerid,
        DATE_TRUNC('month',vtc_datecreated) as mth,
        channel,
        SUM(vtc_amount) AS rm,
        COUNT(*) AS cnt,
        COUNT(distinct vac_customerid) as distinct_customercnt
    FROM (SELECT vac_customerid,
                        vtc_datecreated,
                        abs(vtc_amount/100.0) AS vtc_amount, 'BANK' as channel
                    FROM aggregation_layer.transaction_customer_merchant
                    WHERE vtc_category = 'DEPOSIT'
                        AND vtc_subcategory = 'BANK'
                        --AND (vtc_datecreated + interval '8 HOURS')::DATE BETWEEN '2020-05-01' AND '2021-04-30'
                        AND vtc_datecreated::DATE BETWEEN '2021-01-01' AND '2021-05-31'

                    UNION ALL

                    SELECT customerid AS vac_customerid,
                        datetransaction AS vtc_datecreated,
                        gtv AS vtc_amount,
                        origin AS channel
                    FROM (
                            (
                                SELECT customerid,
                                    datetransaction,
                                    gtv,
                                    subtype,
                                    origin
                                FROM (
                                        (
                                            SELECT customerid,
                                                datecreated + INTERVAL '8 HOURS' AS datetransaction,
                                                gtv,
                                                subtype,
                                                origin
                                            FROM (
                                                    SELECT *
                                                    FROM (
                                                            SELECT DISTINCT customerid AS customerid2,
                                                                id AS cardid2,
                                                                    CASE
                                                                    WHEN cardtype = '660cb6fe7437d4b40e4a04b706b93f70' THEN 'CREDIT'
                                                                    WHEN cardtype = '48aee20d947736a18c6e9d09b526f75a' THEN 'CHARGED'
                                                                    WHEN cardtype = 'd2f9212ec793c0cbc8240ae06a04eab7' THEN 'DEBIT'
                                                                    WHEN cardtype = '834e703cfc57d565c394f2a3b2e71261' THEN 'PREPAID'
                                                                END AS origin
                                                            FROM adyenpg.cardinformation
                                                        ) A
                                                        INNER JOIN (
                                                            SELECT *
                                                            FROM (
                                                                    SELECT *,
                                                                        ROW_NUMBER() over (
                                                                            partition by id
                                                                            ORDER BY __last_sync_ts desc
                                                                        ) AS dedup
                                                                    FROM adyenpg.transaction
                                                                    WHERE datecreated + INTERVAL '8 HOURS' BETWEEN '2021-01-01' AND '2021-05-31'
                                                                )
                                                            WHERE dedup = 1
                                                                AND (
                                                                    status = 'success'
                                                                    OR status = 'SUCCESS'
                                                                )
                                                        ) B ON (A.customerid2 = B.customerid)
                                                        AND (A.cardid2 = B.cardid)
                                                ) C
                                                INNER JOIN (
                                                    SELECT DISTINCT id,
                                                        gtv,
                                                        upper(subtype) AS subtype
                                                    FROM (
                                                            SELECT *
                                                            FROM (
                                                                    SELECT datecreated + interval '8 hour' AS _time,
                                                                        abs(amount / 100.0) AS GTV,
                                                                        ROW_NUMBER() over (partition by id ORDER BY __last_sync_ts desc) AS dedup,
                                                                        *
                                                                    FROM vault.transaction_customer
                                                                    WHERE _time >= '2021-01-01'
                                                                        AND category = 'DEPOSIT'
                                                                        AND subcategory = 'CARD'
                                                                )
                                                            WHERE dedup = 1
                                                                AND (
                                                                    status = 'CAPTURED'
                                                                )
                                                        )
                                                ) D ON (D.id = C.vaulttransactionid)
                                        )

                                        UNION ALL

                                        (
                                            SELECT customerid4 AS customerid,
                                                _time AS datetransaction,
                                                gtv,
                                                upper(cardnetwork) AS subtype,
                                                cardtype AS origin
                                            FROM (
                                                    SELECT customerid AS customerid3,
                                                        cardid,
                                                        _time,
                                                        gtv
                                                    FROM (
                                                            SELECT *,
                                                                createddate + interval '8 hour' AS _time,
                                                                abs(amount / 100.0) AS GTV,
                                                                ROW_NUMBER() over (partition by id ORDER BY __last_sync_ts desc) AS dedup
                                                            FROM revpay.transaction
                                                            WHERE _time BETWEEN '2021-01-01' AND '2021-05-31'
                                                        )
                                                    WHERE dedup = 1
                                                        AND (
                                                            status = 'success'
                                                            OR status = 'SUCCESS'
                                                        )
                                                ) B
                                                INNER JOIN (
                                                    SELECT customerid AS customerid4,
                                                        cardtype,
                                                        id,
                                                        cardnetwork
                                                    FROM (
                                                            SELECT *,
                                                                ROW_NUMBER() over (partition by id ORDER BY __last_sync_ts desc) AS dedup
                                                            FROM revpay.cardinformation
                                                        )
                                                    WHERE dedup = 1
                                                        AND cardnetwork is not NULL
                                                        AND cardtype is not NULL
                                                ) A ON (A.id = B.cardid)
                                                AND (customerid3 = customerid4)
                                        )
                                    ) E
                            )
                        )
                
        )
GROUP BY 1,2
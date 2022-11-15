select * from VOUCHER where SER_NUM IN ('020000002479039','020000002479141','020000002479111','020000002479037','020000002479221');
select * from VOUCHER
         --where ORDER_ID=1000001153
ORDER BY order_id desc;
select * from API_REQUEST where REQUEST_TIME>=trunc(sysdate) and TRANS_ID IN (
    'ct2_mpl_api_1665026662586',
'ct2_mpl_api_1665027821074',
'ct2_mpl_api_1663660235648',
'ct2_mpl_api_1665027822959',
'ct2_mpl_api_1663660239273'
    );

SELECT *
FROM VOUCHER_ORDER
where ORDER_id=1000001157
ORDER BY ORDER_ID desc;

SELECT *
FROM VOUCHER_ORDER_DETAIL where ORDER_ID=1000001157;

SELECT *
FROM temp_dc_use_20220905;


select * from EMAIL_HISTORY where ORDER_ID=1000003239;
select * from EMAIL_QUEUE;


--
select * from job where p1  ='3201';--email id (email_queue)
--Cập nhật lại trạng thái job bị lỗi (id job lấy trên log tiến trình gửi email)
select * from job where JOB_ID in (11167,11169,11173,11171,11175);
update job set status = 0 where job_id in (11155);
COMMIT ;

/*CREATE TABLE temp_dc_use_20220905 AS*/
SELECT a.profile_code, COUNT(1) amount, b.order_code
FROM voucher a,
     voucher_order b
WHERE a.order_id = b.order_id
  AND a.used = '1'
  AND a.use_tim >= TO_DATE('16/01/2022', 'dd/mm/yyyy')
  AND a.use_tim <= TO_DATE('30/04/2022', 'dd/mm/yyyy')
GROUP BY a.profile_code, b.order_code
;

SELECT *
FROM voucher;


SELECT a.card_name, SUM(b.amount) amount, a.price, SUM(b.amount) * a.price AS total
FROM temp_20220905 a,
     temp_dc_use_20220905 b
WHERE a.res_order_id = b.order_code
  AND a.card_name = b.profile_code
GROUP BY a.card_name, a.price
ORDER BY a.card_name
;

SELECT *
from temp_dc_use_20220905;


SELECT SUM(a.cap_max) amount, SUM(b.amount * a.price) AS total
FROM temp_20220905 a,
     temp_dc_use_20220905 b
WHERE a.res_order_id = b.order_code
  AND a.card_name = b.profile_code;

SELECT a.com_name, SUM(a.cap_max) amount, SUM(b.amount * a.price) AS total
FROM temp_comp_20220906 a,
     temp_dc_use_20220905 b
WHERE a.res_order_id = b.order_code
  AND a.card_name = b.profile_code
group by a.com_name
;

select *
from DSP_COMPANY
where COM_ID = 881;

select *
from VOUCHER_PROFILE
order by PROFILE_ID;

select *
from VOUCHER
where ORDER_ID = '1000000891'
  and USED <> '1';


begin
    summary_order_daily(sysdate);
end;


/*insert into RPT_ORDER_SUMMARY_DAILY*/

select (select order_code from voucher_order o where o.order_id = a.order_id) order_code,
       a.*
from (select TO_DATE('27/08/2022', 'dd/mm/yyyy') sum_dat,
             trunc(cre_dat)                      cre_dat,
             order_id,
             addon,
             profile_code,
             count(1)                            total,
             sum(case
                     when use_tim >= TO_DATE('27/08/2022', 'dd/mm/yyyy') and
                          use_tim < TO_DATE('28/08/2022', 'dd/mm/yyyy') then 1
                     else 0
                 end)                            used_in_period,
             sum(case
                     when use_tim < TO_DATE('28/08/2022', 'dd/mm/yyyy') then 1
                     else 0
                 end)                            used,
             sum(case
                     when use_tim is null or use_tim >= TO_DATE('27/08/2022', 'dd/mm/yyyy') then 1
                     else 0
                 end)                            not_yet,
             sum(case
                     when exp_dat >= TO_DATE('27/08/2022', 'dd/mm/yyyy') and
                          exp_dat < TO_DATE('28/08/2022', 'dd/mm/yyyy') and USED = 0 then 1
                     else 0
                 end)                            expired_in_period
      from voucher
      where ORDER_ID = '1000001270'
        and exp_dat >= TO_DATE('27/08/2022', 'dd/mm/yyyy')
        and cre_dat < TO_DATE('28/08/2022', 'dd/mm/yyyy')
      group by TO_DATE('27/08/2022', 'dd/mm/yyyy'), trunc(cre_dat), order_id, addon, profile_code) a;


select * from RPT_ORDER_SUMMARY_DAILY where TOTAL=EXPIRED_IN_PERIOD


                                        and TOTAL=USED+NOT_YET;

select * from VOUCHER where ORDER_ID = 1000001419;

select * from RPT_ORDER_SUMMARY_DAILY where ORDER_ID = 1000001270 order by  SUM_DAT;


update RPT_ORDER_SUMMARY_DAILY set EXPIRED_IN_PERIOD=NOT_YET where TOTAL=EXPIRED_IN_PERIOD;
commit ;
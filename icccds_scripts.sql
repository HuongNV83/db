/*DROP TABLE shop;
DROP TABLE company;*/

CREATE TABLE shop
(
    shop_id      NUMBER(20)         NOT NULL
        CONSTRAINT shop_pk PRIMARY KEY,
    parent_id    NUMBER(20),
    shop_code    VARCHAR2(20 BYTE)  NOT NULL
        CONSTRAINT shop_uk
            UNIQUE,
    shop_level   NUMBER(2)          NOT NULL,
    name         VARCHAR2(80 BYTE)  NOT NULL,
    contact_name VARCHAR2(150 BYTE),
    mobile       VARCHAR2(100 BYTE),
    fax          VARCHAR2(100 BYTE),
    email        VARCHAR2(100 BYTE),
    status       VARCHAR2(1 BYTE)   NOT NULL,
    address      VARCHAR2(150 BYTE) NOT NULL,
    description  VARCHAR2(150 BYTE),
    web_user_id  NUMBER(10)         NOT NULL
        CONSTRAINT shop_am_user_fk1 REFERENCES am_user,
    create_by    VARCHAR(50)        NOT NULL,
    create_date  DATE DEFAULT SYSDATE,
    upd_by       VARCHAR(50),
    upt_date     DATE DEFAULT SYSDATE
);

CREATE SEQUENCE shop_seq
    INCREMENT BY 1
    START WITH 1
    MINVALUE 1
    NOCYCLE
    NOORDER
    CACHE 20
/



CREATE TABLE company
(
    com_id         NUMBER(20)     NOT NULL
        CONSTRAINT company_pk PRIMARY KEY,
    parent_id      NUMBER(20),
    com_name       NVARCHAR2(200) NOT NULL,
    shop_id        NUMBER(20)     NOT NULL,
    tax_code       VARCHAR2(50),
    bus_code       VARCHAR2(15),
    mobile         VARCHAR2(15),
    email          VARCHAR2(100),
    status         VARCHAR2(1)    NOT NULL,
    description    VARCHAR2(200),
    comp_level     NUMBER(2)      NOT NULL,
    rep_name       VARCHAR2(50),
    rep_mobile     VARCHAR2(15),
    rep_position   VARCHAR2(50),
    province       VARCHAR2(100),
    city           VARCHAR2(100),
    district       VARCHAR2(100),
    ward           VARCHAR2(100),
    address        VARCHAR2(400),
    web_user_id    NUMBER(10)     NOT NULL
        CONSTRAINT comp_am_user_fk1 REFERENCES am_user,
    api_user_id    NUMBER(10)     NOT NULL
        CONSTRAINT comp_am_user_fk2 REFERENCES am_user,
    public_key     CLOB,
    public_key_upt DATE,
    file_path      VARCHAR2(200),
    create_by      VARCHAR(50)    NOT NULL,
    create_date    DATE DEFAULT SYSDATE,
    upd_by         VARCHAR(50),
    upt_date       DATE DEFAULT SYSDATE
)
/

CREATE SEQUENCE company_seq
    INCREMENT BY 1
    START WITH 1
    MINVALUE 1
    NOCYCLE
    NOORDER
    CACHE 20
/

CREATE TABLE shop_level
(
    id         NUMBER(10)    NOT NULL
        CONSTRAINT shop_level_pk
            PRIMARY KEY,
    shop_level NUMBER(1)     NOT NULL
        CONSTRAINT shop_level_uk UNIQUE,
    name       VARCHAR2(200) NOT NULL
)/

INSERT INTO shop_level
VALUES (1, 1, 'Cấp 1');
INSERT INTO shop_level
VALUES (2, 2, 'Cấp 2');
INSERT INTO shop_level
VALUES (3, 3, 'Cấp 3');
INSERT INTO shop_level
VALUES (4, 4, 'Cấp 4');
COMMIT;


CREATE TABLE sub_service
(
    isdn           VARCHAR2(20)          NOT NULL,
    service        VARCHAR2(50)          NOT NULL,
    start_time     DATE                  NOT NULL,
    end_time       DATE                  NOT NULL,
    profile_code   VARCHAR2(30),
    initial_amount NUMBER(10),
    total_amount   NUMBER(15),
    serial         VARCHAR2(30),
    alert_end_time VARCHAR2(1) DEFAULT 0 NOT NULL,
    last_update    DATE,
    hid            NUMBER(15),
    request_id     VARCHAR2(100),
    channel        VARCHAR2(1)
)
/

COMMENT ON COLUMN sub_service.alert_end_time IS '1: da canh bao, 0: chua canh bao'
/
COMMENT ON COLUMN sub_service.channel IS '1: SMS, 2: WEB, 3: API'
/

CREATE INDEX sub_service_pk
    ON sub_service (isdn, service)
/
CREATE INDEX "SUB_SERVICE_HID_index"
    ON sub_service (hid)
/
CREATE INDEX "SUB_SERVICE_END_TIME_index"
    ON sub_service (end_time)
/


CREATE TRIGGER sub_service_bu
    BEFORE UPDATE
    ON sub_service
    FOR EACH ROW
BEGIN
    IF :new.end_time != :old.end_time AND :old.alert_end_time = '1' THEN
        :new.alert_end_time := '0';
    END IF;
END;
/

CREATE TABLE sub_service_history
(
    hid            NUMBER(15)            NOT NULL,
    isdn           VARCHAR2(20)          NOT NULL,
    service        VARCHAR2(50)          NOT NULL,
    start_time     DATE                  NOT NULL,
    end_time       DATE                  NOT NULL,
    cancel_time    DATE,
    profile_code   VARCHAR2(30),
    initial_amount NUMBER(10),
    total_amount   NUMBER(15),
    serial         VARCHAR2(30),
    alert_end_time VARCHAR2(1) DEFAULT 0 NOT NULL,
    last_update    DATE,
    request_id     VARCHAR2(100),
    channel        VARCHAR2(1)
)
/
GRANT SELECT ON dsp_sub_service TO icccds_owner;

CREATE OR REPLACE FUNCTION check_sub_service(p_isdn IN VARCHAR2,
                                             p_service IN VARCHAR2)
    RETURN NUMBER
    IS
    v_count NUMBER(10) := 0;
BEGIN
    SELECT COUNT(1)
    INTO v_count
    FROM dsp_owner.dsp_sub_service
    WHERE isdn = p_isdn
      AND service = p_service
      AND end_time > SYSDATE;

    IF v_count > 0
    THEN
        RETURN v_count;
    END IF;

    SELECT COUNT(1)
    INTO v_count
    FROM sub_service
    WHERE isdn = p_isdn
      AND service = p_service
      AND end_time > SYSDATE;

    RETURN v_count;
END;
/

GRANT SELECT ON dsp_sms_command TO icccds_owner;

CREATE VIEW sms_command AS
SELECT cmd_id,
       cmd_code,
       cmd_type,
       cmd_msg_content,
       cmd_param_count,
       description,
       cmd_regex,
       status
FROM dsp_sms_command
WHERE sys_type IN (1, 3);


INSERT INTO dsp_sms_command
VALUES (dsp_sms_command_seq.nextval, 'DK_DATA_OK', 'O',
        'Quý khách được cộng thêm {0}MB data tốc độ cao từ datacode (sử dụng tại Việt Nam), thời hạn sử dụng đến {1}.Tắt tất cả ứng dụng internet hoặc khởi động lại máy để được tính cước theo gói đã nạp. Chi tiết liên hệ 9090.',
        0,
        'KH nhắn tin đúng cú pháp, hiện không sử dụng gói datacode thường khác, đúng mã datacode    Quý khách được cộng thêm xMB data tốc độ cao từ datacode (sử dụng tại Việt Nam), thời hạn sử dụng đến dd/mm/yyyy. Chi tiết liên hệ 9090.    ',
        NULL, '1', '1');

INSERT INTO dsp_sms_command
VALUES (dsp_sms_command_seq.nextval, 'DK_DATA', 'I', NULL, 3,
        'KHCN Nạp DATA từ DATA-CODE thông thường. Cú pháp DK_DATA_Ma_data_code(N....)', 'DK DATA N\d{14}', '1', '1');
INSERT INTO dsp_sms_command
VALUES (dsp_sms_command_seq.nextval, 'DK_DATA_ON', 'I', NULL, 3,
        'KHCN Nạp DATA từ DATA-CODE AddOn. Cú pháp DK_DATAON_Ma_data_code (A....)', 'DK DATAON A\d{14}', '1', '1');
INSERT INTO dsp_sms_command
VALUES (dsp_sms_command_seq.nextval, 'DK_CB_1', 'I', NULL, 3, 'Đăng ký dịch vụ KHCN', 'DK CB (90N|D60)\d{12}', '1',
        '1');
INSERT INTO dsp_sms_command
VALUES (dsp_sms_command_seq.nextval, 'DK_CB_2', 'I', NULL, 5, 'Đăng ký dịch vụ KHCN (Đại lý DK)',
        'DK CB \d{15} (90N|D60)\d{12} \d{9}', '1', '1');
INSERT INTO dsp_sms_command
VALUES (dsp_sms_command_seq.nextval, 'DK_DATA_F1', 'O',
        'Quý khách hiện đang có một mã datacode khác còn hiệu lực. Để nạp datacode mới, quý khách vui lòng hủy gói datacode bằng cách soạn HUY_DC gửi 9xxx, trong đó “_” là dấu cách. Hoặc chờ mã datacode cũ hết hạn sử dụng. Chi tiết liên hệ 9090.    ',
        0, 'KH nhắn tin đúng cú pháp, nhưng đang sử dụng gói datacode thường khác    ', NULL, '1', '1');
INSERT INTO dsp_sms_command
VALUES (dsp_sms_command_seq.nextval, 'DK_DATA_F2', 'O',
        'Mã datacode không hợp lệ. Quý khách vui lòng kiểm tra lại mã datacode. Chi tiết liên hệ 9090.', 0,
        'KH nhắn tin đúng cú pháp, hiện không sử dụng gói datacode thường khác, sai mã datacode', NULL, '1', '1');
INSERT INTO dsp_sms_command
VALUES (dsp_sms_command_seq.nextval, 'DK_CB_2_OK', 'O',
        'Gói DC90N đã được đăng ký thành công cho thuê bao {0}. Chi tiết liên hệ 9090. Xin cảm ơn!', 0, 'Thành công',
        NULL, '1', '1');
INSERT INTO dsp_sms_command
VALUES (dsp_sms_command_seq.nextval, 'DK_CB_1_F2', 'O',
        'Quý khách không thuộc đối tượng tham gia chương trình. Chi tiết liên hệ 9090. Xin cảm ơn!', 0,
        'Quý khách không thuộc đối tượng tham gia chương trình. Chi tiết liên hệ 9090. Xin cảm ơn!', NULL, '1', '1');
INSERT INTO dsp_sms_command
VALUES (dsp_sms_command_seq.nextval, 'DK_CB_2_F1', 'O',
        'Thông tin datacode không hợp lệ. Quý khách vui lòng kiểm tra lại. Chi tiết liên hệ 9090. Xin cảm ơn!', 0,
        'Thông tin datacode không hợp lệ. Quý khách vui lòng kiểm tra lại. Chi tiết liên hệ 9090. Xin cảm ơn!', NULL,
        '1', '1');
INSERT INTO dsp_sms_command
VALUES (dsp_sms_command_seq.nextval, 'DK_CB_2_F2', 'O',
        'Thuê bao đăng ký không thuộc đối tượng tham gia chương trình. Chi tiết liên hệ 9090. Xin cảm ơn!', 0,
        'Thuê bao đăng ký không thuộc đối tượng tham gia chương trình. Chi tiết liên hệ 9090. Xin cảm ơn!', NULL, '1',
        '1');
INSERT INTO dsp_sms_command
VALUES (dsp_sms_command_seq.nextval, 'DK_CB_2_F3', 'O', 'Thuê bao bán hàng {0} không phải là thuê bao VAS!', 0,
        'Thuê bao bán hàng {0} không phải là thuê bao VAS!', NULL, '1', '1');
INSERT INTO dsp_sms_command
VALUES (dsp_sms_command_seq.nextval, 'DK_CB_1_OK', 'O',
        'Gói DC90N đã được đăng ký thành công. Quý khách được miễn phí thoại nội mạng cho tất cả các cuộc gọi dưới 20 phút, 50 phút gọi liên mạng trong nước, 4GB data tốc độ cao/ngày. HSD gói: {0}. Từ chu kỳ thứ 2 trở đi, giá gói 90.000 đ/30 ngày. Chi tiết liên hệ 9090. Xin cảm ơn!',
        0, 'Thành công', NULL, '1', '1');


UPDATE dsp_sms_command
SET sys_type ='3'
WHERE cmd_code IN
      ('DK_FAIL_ADD_DATA', 'DK_FAIL', 'DK_FAIL_NO_RETRY', 'NO_GPRS', 'SUB_NOT_EXIST', 'LOCK_ISDN', 'VOUCHER_USED',
       'VOUCHER_NOT_FOUND', 'INVALID_FORMAT', 'SYSTEM_ERROR');

COMMIT;

CREATE TABLE mt_queue
(
    id           NUMBER(15)            NOT NULL
        CONSTRAINT mt_queue_pk
            PRIMARY KEY,
    request_id   NUMBER(15),
    trans_id     VARCHAR2(1000),
    isdn         VARCHAR2(15)          NOT NULL,
    content      VARCHAR2(1000)        NOT NULL,
    shortcode    VARCHAR2(15),
    retries      NUMBER(2)   DEFAULT 3 NOT NULL,
    sent_time    TIMESTAMP(7),
    process_time TIMESTAMP(7),
    status       VARCHAR2(1) DEFAULT 0 NOT NULL
)
/

CREATE TABLE mt_history
(
    id           NUMBER(15)     NOT NULL,
    request_id   NUMBER(15),
    trans_id     VARCHAR2(1000),
    isdn         VARCHAR2(15)   NOT NULL,
    content      VARCHAR2(1000) NOT NULL,
    shortcode    VARCHAR2(15),
    retries      NUMBER(2)      NOT NULL,
    sent_time    TIMESTAMP(7),
    process_time TIMESTAMP(7)
)
/

COMMENT ON COLUMN mt_history.isdn IS 'So thue bao, dinh dang 84xxxxxxxxx'
/

COMMENT ON COLUMN mt_history.content IS 'Noi dung tin nhan SMS'
/

COMMENT ON COLUMN mt_history.shortcode IS 'Dau so dich vu'
/

COMMENT ON COLUMN mt_history.retries IS 'So lan retry con lai'
/

CREATE TABLE mo_queue
(
    request_id    NUMBER(15)                   NOT NULL
        CONSTRAINT cb_mo_queue_pk
            PRIMARY KEY,
    isdn          VARCHAR2(15)                 NOT NULL,
    content       VARCHAR2(300)                NOT NULL,
    received_time TIMESTAMP(6) DEFAULT SYSDATE NOT NULL,
    shortcode     VARCHAR2(15)                 NOT NULL,
    retries       NUMBER(2)                    NOT NULL
)
/

CREATE TABLE mo_history
(
    request_id    NUMBER(15)                   NOT NULL,
    trans_id      VARCHAR2(1000),
    isdn          VARCHAR2(15)                 NOT NULL,
    content       VARCHAR2(300)                NOT NULL,
    received_time TIMESTAMP(6) DEFAULT SYSDATE NOT NULL,
    shortcode     VARCHAR2(15)                 NOT NULL,
    retries       NUMBER(2)                    NOT NULL,
    description   VARCHAR2(100)
)
/

INSERT INTO ap_param
VALUES ('DATA', 'SRV_NAME', 'BDATASPONSOR1', 'Ten dich vu DATA');
INSERT INTO ap_param
VALUES ('DATA_ADDON', 'SRV_NAME', 'BDATASPONSOR2', 'Ten dich vu DATA_ADDON');
COMMIT;



create table LOCK_OBJECT
(
    LOCKED_OBJECT VARCHAR2(50) not null,
    ISSUE_DATE    DATE         not null,
    COUNT         NUMBER(1)    not null,
    TYPE          VARCHAR2(1)  not null,
    constraint LOCK_OBJECT_UK
        unique (LOCKED_OBJECT, ISSUE_DATE)
)
/

comment on column LOCK_OBJECT.LOCKED_OBJECT is 'Khoa so thue bao (ISDN) hoac API user'
/

comment on column LOCK_OBJECT.TYPE is '0: isdn; 1: api_user'
/


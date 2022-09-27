-- SYS 관리자 계정 이용
ALTER SESSION SET "_ORACLE_SCRIPT" = TRUE;

-- 사용자 계정 생성
CREATE USER sh IDENTIFIED BY sh1234;

-- 생성한 사용자 계정에 권한을 부여
GRANT CONNECT, RESOURCE, CREATE VIEW TO sh;

-- 테이블 스페이스 할당
ALTER USER sh DEFAULT 
TABLESPACE SYSTEM QUOTA UNLIMITED ON SYSTEM;


---------------------------------------------------------------------------
-- sh계정
DROP TABLE MENU;
DROP SEQUENCE SEQ_MENU_NO;

-- MENU 테이블
CREATE TABLE MENU(
	MENU_NO NUMBER,
	MENU_NM VARCHAR2(30) UNIQUE NOT NULL,
	MENU_PRICE NUMBER NOT NULL,
	SALE_FL CHAR(1) DEFAULT 'Y' CHECK( SALE_FL IN ('Y', 'N')),
	CONSTRAINT MENU_NO_NM_PK PRIMARY KEY(MENU_NO)
);


COMMENT ON COLUMN MENU.MENU_NO IS '메뉴 번호';
COMMENT ON COLUMN MENU.MENU_NM IS '메뉴명';
COMMENT ON COLUMN MENU.MENU_PRICE IS '메뉴 가격';
COMMENT ON COLUMN MENU.SALE_FL IS '판매 여부';

SELECT * FROM MENU;


CREATE SEQUENCE SEQ_MENU_NO NOCACHE;


INSERT INTO MENU VALUES(SEQ_MENU_NO.NEXTVAL, '아메리카노', 4500, DEFAULT);
INSERT INTO MENU VALUES(SEQ_MENU_NO.NEXTVAL, '카페라떼', 5000, DEFAULT);
INSERT INTO MENU VALUES(SEQ_MENU_NO.NEXTVAL, '카페모카', 5500, DEFAULT);
INSERT INTO MENU VALUES(SEQ_MENU_NO.NEXTVAL, '카라멜마끼아또', 5500, DEFAULT);

COMMIT;


-- 메뉴 가격 변동
UPDATE MENU SET MENU_PRICE = 6000
WHERE SALE_FL = 'Y'
AND MENU_NO = 5;

-- 메뉴 삭제 
UPDATE MENU SET SALE_FL = 'N'
WHERE SALE_FL = 'Y'
AND MENU_NO = 5;



---------------------------------------------------------------------
-- 주문내역 테이블
DROP SEQUENCE SEQ_ORDER_NO;
DROP TABLE ORDER_TB;


CREATE TABLE ORDER_TB(
	ORDER_NO NUMBER PRIMARY KEY,
	MENU_NO NUMBER,
	ORDER_QUENTITY NUMBER DEFAULT 0 NOT NULL,
	ORDER_DATE DATE DEFAULT SYSDATE,
	CONSTRAINT MENU_NO_FK FOREIGN KEY(MENU_NO) REFERENCES MENU
);

COMMENT ON COLUMN ORDER_TB.ORDER_NO IS '주문 번호';
COMMENT ON COLUMN ORDER_TB.MENU_NO IS '메뉴 번호(FK)';
COMMENT ON COLUMN ORDER_TB.ORDER_QUENTITY IS '판매 수량';
COMMENT ON COLUMN ORDER_TB.ORDER_DATE IS '판매 날짜';

CREATE SEQUENCE SEQ_ORDER_NO NOCACHE;

INSERT INTO ORDER_TB VALUES (SEQ_ORDER_NO.NEXTVAL, 1, 1, DEFAULT);
INSERT INTO ORDER_TB VALUES (SEQ_ORDER_NO.NEXTVAL, 3, 1, DEFAULT);
INSERT INTO ORDER_TB VALUES (SEQ_ORDER_NO.NEXTVAL, 2, 2, DEFAULT);
INSERT INTO ORDER_TB VALUES (SEQ_ORDER_NO.NEXTVAL, 1, 2, TO_DATE('2022-09-24', 'YYYY-MM-DD'));
INSERT INTO ORDER_TB VALUES (SEQ_ORDER_NO.NEXTVAL, 1, 2, TO_DATE('2022-09-25', 'YYYY-MM-DD'));
INSERT INTO ORDER_TB VALUES (SEQ_ORDER_NO.NEXTVAL, 1, 2, TO_DATE('2022-09-', 'YYYY-MM-DD'));
INSERT INTO ORDER_TB VALUES (SEQ_ORDER_NO.NEXTVAL, 1, 2, TO_DATE('2022-09-26', 'YYYY-MM-DD'));

ROLLBACK;
COMMIT;
SELECT * FROM ORDER_TB;


-- 다음 주문 순서
SELECT SEQ_ORDER_NO.NEXTVAL FROM DUAL;



-- 일자별 조회
SELECT '2022-09-27' ORDER_DATE, SUM(MENU_PRICE) 
FROM ORDER_TB
JOIN MENU USING(MENU_NO)
WHERE TO_CHAR(ORDER_DATE, 'YYYY-MM-DD') = '2022-09-27';

SELECT * FROM MENU

-- 메뉴별 판매 수량과 금액 조회
SELECT MENU_NM, SUM(ORDER_QUENTITY) ORDER_QUENTITY, SUM(MENU_PRICE)
FROM MENU 
JOIN ORDER_TB USING(MENU_NO)
WHERE SALE_FL = 'Y'
GROUP BY MENU_NM;





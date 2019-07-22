CREATE OR REPLACE PROCEDURE P_BLOB_TO_FILE(ID VARCHAR2, v_lob_loc BLOB)
AS
	v_buffer 		RAW(32767);
	v_buffer_size 	BINARY_INTEGER;
	v_amount 		BINARY_INTEGER;
	v_offset 		NUMBER(38) := 1;
	v_chunksize 	INTEGER;
	v_out_file UTL_FILE.FILE_TYPE;
BEGIN
   -- -------------------------------------------------------------
   -- | FIND OUT THE CHUNKSIZE FOR THIS LOB COLUMN |
   -- -------------------------------------------------------------
   v_chunksize := DBMS_LOB.GETCHUNKSIZE(v_lob_loc);
   IF (v_chunksize < 32767) THEN
	   v_buffer_size := v_chunksize;
   ELSE
   	v_buffer_size := 32767;
   END IF;
   v_amount := v_buffer_size;
   -- -------------------------------------------------------------
   -- | OPENING THE LOB IS OPTIONAL |
   -- -------------------------------------------------------------
   --BMS_LOB.OPEN(v_lob_loc, DBMS_LOB.LOB_READONLY);
	 -- -------------------------------------------------------------
   -- | WRITE CONTENTS OF THE LOB TO A FILE |
   -- -------------------------------------------------------------
   v_out_file := UTL_FILE.FOPEN('DIR_IMPORTAR', id, 'w', 32767);
	WHILE v_amount >= v_buffer_size LOOP
		DBMS_LOB.READ(lob_loc => v_lob_loc, amount => v_amount, offset => v_offset, buffer => v_buffer);
		v_offset := v_offset + v_amount;
    	UTL_FILE.PUT_RAW (file => v_out_file, buffer => v_buffer, autoflush => true);
      UTL_FILE.FFLUSH(file => v_out_file);
      -- -------------------------------------------------------------
      -- | HEY WAIT, THIS IS A BINARY FILE! WHAT IS THIS NEW_LINE |
      -- | PROCEDURE DOING HERE? THIS WAS A TEST I WAS PERFORMING TO |
      -- | CONFIRM A BUG (bug#: 2883782). IN 9i THERE IS CURRENTLY A |
      -- | RESTRICTION OF A MAXIMUM OF 32K THAT CAN BE WRITTEN WITH |
      -- | PUT_RAW UNLESS YOU INSERT NEW LINE CHARACTERS IN BETWEEN |
      -- | THE DATA. IN 10i THERE IS A NEW BINARY MODE. WHEN FILES ARE |
      -- | OPENED WITH THIS MODE ANY AMOUNT OF RAW DATA CAN BE WRITTEN |
      -- | WITHOUT THE NEED FOR NEW LINES. IN SHORT, THIS IS A BUG |
      -- | THAT, IF IT CREEPS UP IN ORACLE9i, THERE IS NO SOLUTION! |
      -- -------------------------------------------------------------
    	-- UTL_FILE.NEW_LINE(file => v_out_file);
    END LOOP;
    UTL_FILE.FFLUSH(file => v_out_file);
    UTL_FILE.FCLOSE(v_out_file);
    -- -------------------------------------------------------------
    -- | CLOSING THE LOB IS MANDATORY IF YOU HAVE OPENED IT |
    -- -------------------------------------------------------------
END;
/

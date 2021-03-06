CREATE OR REPLACE FUNCTION "uspGetNextBatchOfMessages"(IN p_rows integer, IN p_status smallint, IN p_waketime timestamp without time zone)
  RETURNS TABLE(t_workitemid integer, t_status smallint, t_waketime timestamp without time zone, t_bindingkey character varying, t_innermessage bytea) AS
$BODY$BEGIN

RETURN QUERY
update workItemStatus
set status = 2
from workItemStatus ws
	inner join workItems wi on ws.workItemId = wi.workItemId
where workItemStatus.workItemId in
	(
	select workItemId 
	from workItemStatus ws
	where ws.status = p_status and ws.waketime <= p_wakeTime
	order by ws.wakeTime asc limit p_rows
	)
returning workItemStatus.workItemId, cast(2 as smallint) as status, ws.wakeTime, wi.bindingKey, wi.innerMessage;

END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION "uspGetNextBatchOfMessages"(integer, smallint, timestamp without time zone)
  OWNER TO postgres;

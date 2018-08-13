CREATE OR REPLACE FUNCTION nomenclature.update_genus()
  RETURNS trigger AS
$BODY$
BEGIN
    -- auto update genus when update fullname
    NEW.genus = split_part(NEW.fullname, ' ', 1);
    NEW.genus_zh = g.genus_zh FROM (SELECT genus,genus_zh FROM twp_genus) AS g WHERE g.genus = NEW.genus;
	NEW.plant_type = p.plant_type FROM (SELECT plant_type,family FROM namelist_ptype) AS p WHERE p.family = NEW.family;
    NEW.name = simplyname(NEW.fullname);
    -- auto update timestamp
    NEW.update_time = now();
RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION nomenclature.update_genus()
  OWNER TO psilotum;

CREATE TRIGGER trigger_update_genus
    BEFORE INSERT OR UPDATE
    ON nomenclature.namelist
    FOR EACH ROW
EXECUTE PROCEDURE nomenclature.update_genus();

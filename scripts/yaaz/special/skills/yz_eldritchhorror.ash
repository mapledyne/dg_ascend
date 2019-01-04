import 'util/base/yz_settings.ash';

void eldritchhorror_progress()
{
  if (!to_boolean(get_property("_eldritchTentacleFought"))
      && !dangerous($monster[eldritch tentacle]))
  {
    task("Fight an " + wrap($monster[eldritch tentacle]) + ", for science.");
  }

  if (!have_skill($skill[evoke eldritch horror])) return;
  if (to_boolean(get_property("_eldritchHorrorEvoked"))) return;

  if (to_boolean(setting("aggressive_optimize", "false"))) return;

  task("Cast " + wrap($skill[evoke eldritch horror]));


}

void eldritchhorror()
{
  if (!to_boolean(get_property("_eldritchTentacleFought"))
      && !dangerous($monster[eldritch tentacle]))
  {
    maximize();
    log("Off to fight an " + wrap($monster[eldritch tentacle]) + ", for science.");

    visit_url('place.php?whichplace=forestvillage&action=fv_scientist');
    string page = run_choice(1);
    if (page.contains_text("Combat")) run_combat();
  }

  if (!have_skill($skill[evoke eldritch horror])) return;
  if (to_boolean(get_property("_eldritchHorrorEvoked"))) return;

  if (to_boolean(setting("aggressive_optimize", "false"))) return;

  int cost = mp_cost($skill[evoke eldritch horror]);

  if (cost * 1.5 < my_mp())
  {
    maximize();
    use_skill(1, $skill[evoke eldritch horror]);
  }
}

void main()
{
  eldritchhorror();
}

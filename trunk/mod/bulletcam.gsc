bulletcam( victim )
{
	distance = distance( self.origin, victim.origin )
	
	if( distance < 500 )
	{
		// Im using hide() and actually moving the player ( after after taking their weapon ), as it provides a more seamless transition.
		self hide();
		weapon = self getCurrentWeapon();
		self takeweapon( weapon );
		self freezeControls( true );
		
		self.victimpos = ( victim getTagOrigin("j_head") - ( 0, 0, 47 ) ); // Tag j_head orgin seems to return higher than actual, so fixed that.
		
		bulletcam = spawn( "script_model", ( 0, 0, 0 ) );
		bulletcam.angles = self getPlayerAngles();
		bulletcam.origin = self.origin;
		
		bulletcam setmodel( "tag_origin" );
		self PlayerLinkToAbsolute( bulletcam );
		
		endpos = VectorLerp( bulletcam.origin, self.victimpos, 0.93 ); // <3 vector lerp
		bulletcam MoveTo( endpos, 0.65, 0, 0.2 );
		self freezeControls( false );
	}
}
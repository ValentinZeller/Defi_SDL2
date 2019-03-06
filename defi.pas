program defi2;
{$APPTYPE GUI} //Enlève la console quand on lance le .exe
{$UNITPATH /SDL2}

//BUT: Collectez les pièces en helicoptere
//ENTREE: Position de la souris
//SORTIE: Gagné ou quitter de force
uses SDL2, SDL2_image, SDL2_ttf;

Type Tsprite = RECORD
  texture : PSDL_Texture;
  src,dst : PSDL_Rect;
END;

var
  sdlWindow1 : PSDL_Window;
  sdlRenderer : PSDL_Renderer;
  sdlRect1 : PSDL_Rect;
  //Gestion des Tilesets, sprites
  Helicopter,Coin : Tsprite;
  VictoireRect : PSDL_Rect;
  //Variables pour la boucle principale
  sdlEvent: PSDL_Event;
  exitloop: boolean;
  //Variables pour l'animation des sprites
  tick,sprite : Uint32;
  //Variables pour l'écran de victoire
  sdlSurface1 : PSDL_Surface;
  ttfFont : PTTF_Font;
  sdlColor1: PSDL_Color;
  sdlTexture1 : PSDL_Texture;


procedure affiche(long,nbframe : integer;sprites:Tsprite);
//BUT : Affiche une frame d'un tileset
//ENTREE : long : la largeur du sprite
//         nbframe : le numero de la frame
//         texture : la texture à afficher
//         cadre : le rectangle pour délimiter la frame dans le tileset
//         rect : le rectangle qui délimite la taille et la position à l'affichage à l'écran
begin
  tick := SDL_GetTicks();
  sprite := (tick div 100) mod nbframe;
  sprites.src^.x:=long*sprite;
  SDL_RenderCopy( sdlRenderer, sprites.texture, sprites.src, sprites.dst );
  SDL_RenderPresent(sdlRenderer);
end;

procedure ecranvictoire;
//BUT : Affiche l'écran de victoire
//ENTREE : Rien
//SORTIE : Rien
begin
  if TTF_Init = -1 then HALT;
  ttfFont := TTF_OpenFont( 'assets\Arial.ttf', 40 );

  new(sdlColor1);
  sdlColor1^.r := 255; sdlColor1^.g := 0; sdlColor1^.b := 0;sdlColor1^.a:= 255;

  sdlSurface1 := TTF_RenderText_Solid( ttfFont, 'Victoire !', sdlColor1^);
  sdlTexture1 := SDL_CreateTextureFromSurface( sdlRenderer, sdlSurface1 );
  VictoireRect^.x:= 50;VictoireRect^.y:= 150;VictoireRect^.w:= 350;VictoireRect^.h:= 125;

  SDL_RenderCopy( sdlRenderer, sdlTexture1, nil, VictoireRect );
  SDL_RenderPresent( sdlRenderer );
  SDL_Delay( 2000 );

  dispose(sdlColor1);
  TTF_CloseFont(ttfFont);
  TTF_Quit;
  SDL_FreeSurface( sdlSurface1 );
  SDL_DestroyTexture( sdlTexture1 );
end;

var coins:integer;
begin
  randomize;
  exitloop := false;
  coins:= 0;
  //Initialisation de SDL
  if SDL_Init( SDL_INIT_VIDEO ) < 0 then HALT;

  sdlWindow1 := SDL_CreateWindow( 'Collectez les pieces', SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 500, 500, SDL_WINDOW_SHOWN );
  if sdlWindow1 = nil then HALT;

  sdlRenderer := SDL_CreateRenderer( sdlWindow1, -1, 0 );
  if sdlRenderer = nil then HALT;

  //Création d'un rectangle vert
  new( sdlRect1 );
  sdlRect1^.x := 260; sdlRect1^.y := 10; sdlRect1^.w := 230; sdlRect1^.h := 230;
  SDL_SetRenderDrawColor( sdlRenderer, 0, 255, 0, 255 );
  SDL_RenderDrawRect( sdlRenderer, sdlRect1 );
  SDL_RenderPresent (sdlRenderer);
  SDL_Delay(2000);

  //Chargement d'une image bmp
  sdlTexture1 := IMG_LoadTexture( sdlRenderer, 'assets\rider.bmp' );
  if sdlTexture1 = nil then HALT;
  SDL_RenderCopy( sdlRenderer, sdlTexture1, nil, sdlRect1 );
  SDL_RenderPresent (sdlRenderer);
  SDL_Delay(2000);

  new(Helicopter.src);
  new(Helicopter.dst);
  new(Coin.src);
  new(Coin.dst);
  new(VictoireRect);

  //Création de l'helicoptere
  Helicopter.src^.x:=0;Helicopter.src^.y:=0;Helicopter.src^.w:=128;Helicopter.src^.h:=55;
  Helicopter.dst^.x := 10; Helicopter.dst^.y := 260; Helicopter.dst^.w:=128; Helicopter.dst^.h:=55;
  Helicopter.texture := IMG_LoadTexture( sdlRenderer, 'assets\helicopter.png' );
  if Helicopter.texture = nil then HALT;

  //Création d'une pièece
  Coin.src^.x:=0;Coin.src^.y:=0;Coin.src^.w:=32;Coin.src^.h:=32;
  Coin.dst^.x := random(450); Coin.dst^.y := random(450); Coin.dst^.w:=32; Coin.dst^.h:=32;
  Coin.texture := IMG_LoadTexture( sdlRenderer, 'assets\coin.png' );
  if Coin.texture = nil then HALT;

  //Boucle principale
  new( sdlEvent );
  while exitloop = false do
  begin
    affiche(Coin.dst^.w,5,Coin);
    affiche(Helicopter.dst^.w,4,Helicopter);
    SDL_Delay( 20 );
    SDL_SetRenderDrawColor( sdlRenderer, 0, 0, 0, 255 );
    SDL_RenderClear( sdlRenderer );
    while SDL_PollEvent( sdlEvent ) = 1 do
    begin
      case sdlEvent^.type_ of
        //Touche du clavier
        SDL_KEYDOWN: begin
                       case sdlEvent^.key.keysym.sym of
                         27: exitloop := true;  // ECHAP pour quitter
                         end;
                     end;

        //Mouvement de la souris
        SDL_MOUSEMOTION: begin
                           affiche(Coin.dst^.w,5,Coin);
                           affiche(Helicopter.dst^.w,4,Helicopter);
                           Helicopter.dst^.x := sdlEvent^.motion.x-32; Helicopter.dst^.y := sdlEvent^.motion.y-28;
                           SDL_RenderPresent (sdlRenderer);
                           SDL_Delay( 20 );
                           SDL_SetRenderDrawColor( sdlRenderer, 0, 0, 0, 255 );
                           SDL_RenderClear( sdlRenderer );
                         end;

      end;
      //Si l'helicoptere entre en contact avec un pièce, celle-ci est supprimée et une nouvelle apparait ailleurs
      if (((Helicopter.dst^.x + 32) >= Coin.dst^.x)AND((Helicopter.dst^.x + 32) <= (Coin.dst^.x + Coin.dst^.w))AND((Helicopter.dst^.y + 28 ) >= Coin.dst^.y)AND((Helicopter.dst^.y + 28) <= (Coin.dst^.y + Coin.dst^.h))) then
       begin
        Coin.dst^.x := random(490)+10; Coin.dst^.y := random(450)+10; Coin.dst^.w:=32; Coin.dst^.h:=32;
        coins:= coins + 1;
       end;
      //Si le joueur a récolté 10 pièces, c'est la fin de la boucle
      if (coins = 10) then
        begin
        SDL_DestroyTexture(Coin.texture);
        exitloop := true;
        end;
    end;
    SDL_Delay( 1 );
  end;
  if (coins = 10) then
    begin
      SDL_SetRenderDrawColor( sdlRenderer, 255, 255, 255, 255 );
      SDL_RenderClear( sdlRenderer );
      ecranvictoire;
    end;


  SDL_DestroyRenderer( sdlRenderer );
  SDL_DestroyWindow ( sdlWindow1 );
  SDL_Quit;

end.

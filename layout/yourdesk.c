/*******************************************************************************************
*
*   LayoutName v1.0.0 - Tool Description
*
*   LICENSE: Propietary License
*
*   Copyright (c) 2022 raylib technologies. All Rights Reserved.
*
*   Unauthorized copying of this file, via any medium is strictly prohibited
*   This project is proprietary and confidential unless the owner allows
*   usage in any other form by expresely written permission.
*
**********************************************************************************************/

#include "raylib.h"

#define RAYGUI_IMPLEMENTATION
#include "raygui.h"

//----------------------------------------------------------------------------------
// Controls Functions Declaration
//----------------------------------------------------------------------------------
static void BUTTONADD();
static void BUTTONREMOVE();
static void BUTTONRENAME();
static void BUTTONSTART();
static void LINEADD();

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
int main()
{
    // Initialization
    //---------------------------------------------------------------------------------------
    int screenWidth = 800;
    int screenHeight = 450;

    InitWindow(screenWidth, screenHeight, "layout_name");

    // layout_name: controls initialization
    //----------------------------------------------------------------------------------
    bool BUTTONLINESActive = true;
    float SLIDEPROGRESSValue = 0.0f;
    bool LINESELECTEditMode = false;
    int LINESELECTValue = 0;
    Color LINECOLORPICKValue = { 0, 0, 0, 0 };
    bool LINENUMBEREditMode = false;
    int LINENUMBERValue = 0;
    //----------------------------------------------------------------------------------

    SetTargetFPS(60);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        // TODO: Implement required update logic
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(GetColor(GuiGetStyle(DEFAULT, BACKGROUND_COLOR))); 

            // raygui: controls drawing
            //----------------------------------------------------------------------------------
            GuiPanel((Rectangle){ 32, 24, 1056, 616 }, NULL);
            GuiGroupBox((Rectangle){ 40, 40, 1040, 504 }, "CLASS");
            if (GuiButton((Rectangle){ 80, 568, 136, 48 }, "ADD")) BUTTONADD(); 
            if (GuiButton((Rectangle){ 240, 568, 136, 48 }, "REMOVE")) BUTTONREMOVE(); 
            if (GuiButton((Rectangle){ 400, 568, 136, 48 }, "RENAME")) BUTTONRENAME(); 
            GuiToggle((Rectangle){ 560, 568, 136, 48 }, "SET LINES", &BUTTONLINESActive);
            if (GuiButton((Rectangle){ 824, 560, 176, 64 }, "START")) BUTTONSTART(); 
            GuiPanel((Rectangle){ 320, 480, 512, 48 }, NULL);
            GuiProgressBar((Rectangle){ 336, 496, 480, 16 }, NULL, NULL, &SLIDEPROGRESSValue, 0, 1);
            GuiDummyRec((Rectangle){ 80, 72, 136, 40 }, "PERSON");
            GuiPanel((Rectangle){ 472, 480, 208, 48 }, NULL);
            if (GuiSpinner((Rectangle){ 488, 488, 176, 32 }, NULL, &LINESELECTValue, 0, 100, LINESELECTEditMode)) LINESELECTEditMode = !LINESELECTEditMode;
            GuiPanel((Rectangle){ 864, 152, 200, 264 }, NULL);
            GuiColorPicker((Rectangle){ 880, 176, 144, 136 }, NULL, &LINECOLORPICKValue);
            GuiPanel((Rectangle){ 880, 320, 168, 16 }, NULL);
            if (GuiValueBox((Rectangle){ 880, 352, 112, 40 }, NULL, &LINENUMBERValue, 0, 100, LINENUMBEREditMode)) LINENUMBEREditMode = !LINENUMBEREditMode;
            if (GuiButton((Rectangle){ 1000, 352, 48, 40 }, "ADD")) LINEADD(); 
            //----------------------------------------------------------------------------------

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------

    return 0;
}

//------------------------------------------------------------------------------------
// Controls Functions Definitions (local)
//------------------------------------------------------------------------------------
static void BUTTONADD()
{
    // TODO: Implement control logic
}
static void BUTTONREMOVE()
{
    // TODO: Implement control logic
}
static void BUTTONRENAME()
{
    // TODO: Implement control logic
}
static void BUTTONSTART()
{
    // TODO: Implement control logic
}
static void LINEADD()
{
    // TODO: Implement control logic
}


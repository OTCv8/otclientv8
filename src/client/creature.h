/*
 * Copyright (c) 2010-2017 OTClient <https://github.com/edubart/otclient>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#ifndef CREATURE_H
#define CREATURE_H

#include "thing.h"
#include "outfit.h"
#include "tile.h"
#include "mapview.h"
#include <framework/core/scheduledevent.h>
#include <framework/core/declarations.h>
#include <framework/core/timer.h>
#include <framework/graphics/fontmanager.h>
#include <framework/graphics/cachedtext.h>
#include <framework/ui/uiwidget.h>

 // @bindclass
class Creature : public Thing
{
public:
    enum {
        SHIELD_BLINK_TICKS = 500,
        VOLATILE_SQUARE_DURATION = 1000
    };

    Creature();
    virtual ~Creature();

    virtual void draw(const Point& dest, bool animate = true, LightView* lightView = nullptr);
    virtual void drawOutfit(const Rect& destRect, Otc::Direction direction = Otc::InvalidDirection, const Color& color = Color::white);

    void drawInformation(const Point& point, bool useGray, const Rect& parentRect, int drawFlags);

    bool isInsideOffset(Point offset);

    void setId(uint32 id) { m_id = id; }
    void setName(const std::string& name);
    void setManaPercent(int8 value) { m_manaPercent = value; }
    void setHealthPercent(uint8 healthPercent);
    void setDirection(Otc::Direction direction);
    void setOutfit(const Outfit& outfit);
    void setOutfitColor(const Color& color, int duration);
    void setLight(const Light& light) { m_light = light; }
    void setSpeed(uint16 speed);
    void setBaseSpeed(double baseSpeed);
    void setSkull(uint8 skull);
    void setShield(uint8 shield);
    void setEmblem(uint8 emblem);
    void setType(uint8 type);
    void setIcon(uint8 icon);
    void setSkullTexture(const std::string& filename);
    void setShieldTexture(const std::string& filename, bool blink);
    void setEmblemTexture(const std::string& filename);
    void setTypeTexture(const std::string& filename);
    void setIconTexture(const std::string& filename);
    void setPassable(bool passable) { m_passable = passable; }
    void setSpeedFormula(double speedA, double speedB, double speedC);

    void addTimedSquare(uint8 color);
    void removeTimedSquare() { m_showTimedSquare = false; }

    void showStaticSquare(const Color& color) { m_showStaticSquare = true; m_staticSquareColor = color; }
    void hideStaticSquare() { m_showStaticSquare = false; }

    void setInformationColor(const Color& color) { m_useCustomInformationColor = true; m_informationColor = color; }
    void resetInformationColor() { m_useCustomInformationColor = false; }

    Point getInformationOffset() { return m_informationOffset; }
    void setInformationOffset(int x, int y) { m_informationOffset = Point(x, y); }

    void setText(const std::string& text, const Color& color);
    std::string getText();
    void clearText() { setText("", Color::white); }

    uint32 getId() { return m_id; }
    std::string getName() { return m_name; }
    uint8 getHealthPercent() { return m_healthPercent; }
    int8 getManaPercent() { return m_manaPercent; }
    Otc::Direction getDirection() { return m_direction; }
    Otc::Direction getWalkDirection() { return m_walkDirection; }
    Outfit getOutfit() { return m_outfit; }
    int getOutfitNumber() { return m_outfitNumber; }
    Light getLight() { return m_light; }
    uint16 getSpeed() { return m_speed; }
    double getBaseSpeed() { return m_baseSpeed; }
    uint8 getSkull() { return m_skull; }
    uint8 getShield() { return m_shield; }
    uint8 getEmblem() { return m_emblem; }
    uint8 getType() { return m_type; }
    uint8 getIcon() { return m_icon; }
    bool isPassable() { return m_passable; }
    Point getDrawOffset();
    int getStepDuration(bool ignoreDiagonal = false, Otc::Direction dir = Otc::InvalidDirection);
    Point getWalkOffset(bool inNextFrame = false) { return inNextFrame ? m_walkOffsetInNextFrame : m_walkOffset; }
    Position getLastStepFromPosition() { return m_lastStepFromPosition; }
    Position getLastStepToPosition() { return m_lastStepToPosition; }
    float getStepProgress() { return m_walkTimer.ticksElapsed() / getStepDuration(); }
    int getStepTicksLeft() { return getStepDuration() - m_walkTimer.ticksElapsed(); }
    ticks_t getWalkTicksElapsed() { return m_walkTimer.ticksElapsed(); }
    double getSpeedFormula(Otc::SpeedFormula formula) { return m_speedFormula[formula]; }
    bool hasSpeedFormula();
    std::array<double, Otc::LastSpeedFormula> getSpeedFormulaArray() { return m_speedFormula; }
    virtual Point getDisplacement();
    virtual int getDisplacementX();
    virtual int getDisplacementY();
    virtual int getExactSize(int layer = 0, int xPattern = 0, int yPattern = 0, int zPattern = 0, int animationPhase = 0);
    PointF getJumpOffset() { return m_jumpOffset; }

    void updateShield();

    // walk related
    int getWalkAnimationPhases();
    virtual void turn(Otc::Direction direction);
    void jump(int height, int duration);
    virtual void walk(const Position& oldPos, const Position& newPos);
    virtual void stopWalk();
    void allowAppearWalk(uint16_t stepSpeed) { m_allowAppearWalk = true; m_stepDuration = stepSpeed; }

    bool isWalking() { return m_walking; }
    bool isRemoved() { return m_removed; }
    bool isInvisible() { return m_outfit.getCategory() == ThingCategoryEffect && m_outfit.getAuxId() == 13; }
    bool isDead() { return m_healthPercent <= 0; }
    bool canBeSeen() { return !isInvisible() || isPlayer(); }

    bool isCreature() { return true; }

    const ThingTypePtr& getThingType();
    ThingType *rawGetThingType();

    virtual void onPositionChange(const Position& newPos, const Position& oldPos);
    virtual void onAppear();
    virtual void onDisappear();
    virtual void onDeath();

    virtual bool isPreWalking() { return false; }
    virtual Position getPrewalkingPosition(bool beforePrewalk = false) { return m_position; }

    TilePtr getWalkingTileOrTile() {
        return m_walkingTile ? m_walkingTile : getTile();
    }

    virtual bool isServerWalking() { return true; }

    void setElevation(uint8 elevation) {
        m_elevation = elevation;
    }
    uint8 getElevation() {
        return m_elevation;
    }

    // widgets
    void addTopWidget(const UIWidgetPtr& widget);
    void addBottomWidget(const UIWidgetPtr& widget);
    void addDirectionalWidget(const UIWidgetPtr& widget);
    void removeTopWidget(const UIWidgetPtr& widget);
    void removeBottomWidget(const UIWidgetPtr& widget);
    void removeDirectionalWidget(const UIWidgetPtr& widget);
    std::list<UIWidgetPtr> getTopWidgets();
    std::list<UIWidgetPtr> getBottomWidgets();
    std::list<UIWidgetPtr> getDirectionalWdigets();
    void clearWidgets();
    void clearTopWidgets();
    void clearBottomWidgets();
    void clearDirectionalWidgets();
    void drawTopWidgets(const Point& rect, const Otc::Direction direction);
    void drawBottomWidgets(const Point& rect, const Otc::Direction direction);

protected:
    virtual void updateWalkAnimation(int totalPixelsWalked);
    virtual void updateWalkOffset(int totalPixelsWalked, bool inNextFrame = false);
    void updateWalkingTile();
    virtual void nextWalkUpdate();
    virtual void updateWalk();
    virtual void terminateWalk();

    void updateOutfitColor(Color color, Color finalColor, Color delta, int duration);
    void updateJump();

    uint32 m_id;
    std::string m_name;
    uint8 m_healthPercent;
    int8 m_manaPercent;
    Otc::Direction m_direction;
    Otc::Direction m_walkDirection;
    Outfit m_outfit;
    int m_outfitNumber = 0;
    Light m_light;
    int m_speed;
    double m_baseSpeed;
    uint8 m_skull;
    uint8 m_shield;
    uint8 m_emblem;
    uint8 m_type;
    uint8 m_icon;
    TexturePtr m_skullTexture;
    TexturePtr m_shieldTexture;
    TexturePtr m_emblemTexture;
    TexturePtr m_typeTexture;
    TexturePtr m_iconTexture;
    stdext::boolean<true> m_showShieldTexture;
    stdext::boolean<false> m_shieldBlink;
    stdext::boolean<false> m_passable;
    Color m_timedSquareColor;
    Color m_staticSquareColor;
    Color m_nameColor;
    stdext::boolean<false> m_showTimedSquare;
    stdext::boolean<false> m_showStaticSquare;
    stdext::boolean<true> m_removed;
    CachedText m_nameCache;
    Color m_informationColor;
    bool m_useCustomInformationColor = false;
    Point m_informationOffset;
    Color m_outfitColor;
    ScheduledEventPtr m_outfitColorUpdateEvent;
    Timer m_outfitColorTimer;

    static std::array<double, Otc::LastSpeedFormula> m_speedFormula;

    // walk related
    int m_walkAnimationPhase;
    int m_walkedPixels;
    uint m_footStep;
    Timer m_walkTimer;
    ticks_t m_footLastStep;
    TilePtr m_walkingTile;
    stdext::boolean<false> m_walking;
    stdext::boolean<false> m_allowAppearWalk;
    ScheduledEventPtr m_walkUpdateEvent;
    ScheduledEventPtr m_walkFinishAnimEvent;
    EventPtr m_disappearEvent;
    Point m_walkOffset;
    Point m_walkOffsetInNextFrame;
    Otc::Direction m_lastStepDirection;
    Position m_lastStepFromPosition;
    Position m_lastStepToPosition;
    Position m_oldPosition;
    uint8 m_elevation = 0;
    uint16 m_stepDuration = 0;

    // jump related
    float m_jumpHeight = 0;
    float m_jumpDuration = 0;
    PointF m_jumpOffset;
    Timer m_jumpTimer;

    // for bot
    StaticTextPtr m_text;

    // widgets
    std::list<UIWidgetPtr> m_bottomWidgets;
    std::list<UIWidgetPtr> m_directionalWidgets;
    std::list<UIWidgetPtr> m_topWidgets;
};

// @bindclass
class Npc : public Creature
{
public:
    bool isNpc() { return true; }
};

// @bindclass
class Monster : public Creature
{
public:
    bool isMonster() { return true; }
};

#endif

print("Blue% Loaded")

G.C.XMULT = G.C.CHIPS
G.C.RED = G.C.BLUE

SMODS.Atlas {
    key = "shop_sign",
    path = "ShopSignAnimation.png",
    raw_key = true,
    atlas_table = 'ANIMATION_ATLAS',
    frames = 4,
    px = 113,
    py = 56
}

SMODS.Atlas {
    key = "stickers",
    path = "stickers.png",
    raw_key = true,
    px = 73,
    py = 95
}

SMODS.Atlas {
    key = "modicon",
    path = "modicon.png",
    px = 32,
    py = 32
}

BluePercent = {
    allowed = {
        'j_gluttenous_joker',
        'j_jolly',
        'j_sly',
        'j_fibonacci',
        'j_odd_todd',
        'j_ice_cream',
        'j_splash',
        'j_blue_joker',
        'j_superposition',
        'j_dna',
        'j_seance',
        'j_cloud_9',
        'j_luchador',
        'j_trousers',
        'j_walkie_talkie',
        'j_seltzer',
        'j_ancient',
        'j_castle',
        'j_onyx_agate',
        'j_blueprint',
        'j_flower_pot',
        'j_seeing_double',
        'j_smeared',
        'j_duo',
        'j_idol',
        'j_satellite',
        'j_astronomer',
        'j_triboulet',

        'v_clearance_sale',
        'v_liquidation',
        'v_hone',
        'v_glow_up',
        'v_telescope',
        'v_grabber',
        'v_tong',
        'v_planet_merchant',
        'v_tarot_tycoon',
        'v_seed_money',
        'v_money_tree',
        'v_magic_trick',
        'v_illusion',
        'v_paint_brush',
        'v_palette',

        'c_mercury',
        'c_venus',
        'c_earth',
        'c_mars',
        'c_jupiter',
        'c_saturn',
        'c_uranus',
        'c_neptune',
        'c_pluto',
        'c_planet_x',
        'c_ceres',
        'c_eris',

        'c_fool',
        'c_magician',
        'c_high_priestess',
        'c_empress',
        'c_emperor',
        'c_heirophant',
        'c_lovers',
        'c_chariot',
        'c_justice',
        'c_hermit',
        'c_wheel_of_fortune',
        'c_strength',
        'c_hanged_man',
        'c_death',
        'c_temperance',
        'c_devil',
        'c_tower',
        'c_moon',
        'c_judgement',

        'c_familiar',
        'c_grim',
        'c_incantation',
        'c_talisman',
        'c_aura',
        'c_wraith',
        'c_sigil',
        'c_ouija',
        'c_ectoplasm',
        'c_immolate',
        'c_ankh',
        'c_deja_vu',
        'c_hex',
        'c_trance',
        'c_medium',
        'c_cryptid',
        'c_soul',
        'c_black_hole',
    },
}

function BluePercent:is_name_allowed(card_name)
    for _, name in ipairs(self.allowed) do
        if name == card_name then
            return true
        end
    end
    return false
end

function BluePercent:is_allowed(e, card)
    local card = card or e.config.ref_table

    if self:is_name_allowed(card.config.center_key) then return true end
    if card.edition then
        -- also includes negatives because they could be blue and i am not hardcoding those
        if card.edition.type == "foil" or card.edition.type == "negative" then return true end
    end

    if card.seal then
        if card.seal == "Blue" then return true end
    end

    if card.config.center_key == "m_bonus" then return true end

    if card:is_suit("Clubs") then return true end

    return false
end
local lose_game = function() if G.STAGE == G.STAGES.RUN then G.STATE = G.STATES.GAME_OVER; G.STATE_COMPLETE = false end end

local old_skip = G.FUNCS.skip_blind
---@diagnostic disable-next-line: duplicate-set-field
G.FUNCS.skip_blind = function(e)
    if e.config.ref_table.ability.blind_type == "Small" then
        if SMODS.Mods["bluepercent"].config.skip_penalty == true then
            lose_game()
        else
            G.FUNCS.BP_fuck_you()
            return
        end
    end
    return old_skip(e)
end

local old_select = G.FUNCS.select_blind

---@diagnostic disable-next-line: duplicate-set-field
G.FUNCS.select_blind = function(e)
    if e.config.ref_table.key == "bl_big" then
        if SMODS.Mods["bluepercent"].config.skip_penalty == true then
            lose_game()
        else
            G.FUNCS.BP_fuck_you()
            return
        end
    end
    return old_select(e)
end

SMODS.current_mod.calculate = function(card, context)
    if SMODS.Mods["bluepercent"].config.enable_club_kills ~= true then return end
    if context.before then
        for index, found_card in pairs(context.full_hand) do
            if not (found_card:is_suit("Clubs") or found_card.debuff == true) then
                if found_card.config.center_key ~= "m_wild" and not BluePercent:is_allowed(nil, found_card) then
                    lose_game()
                end
            end
        end
    end
end

-- SMODS.JimboQuip{
--     key = 'holyshit',
--     type = 'win',
--     loc_txt = {
--         ['en-us'] = {
--             "Holy shit. You did it.",
--         }
--     },
--     filter = function()
--         return true, { rarity = 0 }
--     end
-- }

-- SMODS.JimboQuip{
--     key = 'damn',
--     type = 'loss',
--     loc_txt = {
--         ['en-us'] = {
--             "This is the first time",
--             "you've blue yourself",
--             "in about 30 seconds!"
--         }
--     }
-- }

function G.FUNCS.BP_warn(e)
    G.FUNCS.BP_temp_buy = function(inner_e)
        -- the amount of time it took me to realize it was e.config.old_button and not e.old_button is time i will never get back
        G.FUNCS[e.config.old_button](e) -- get it to reference the original card rather than the button
        G.FUNCS.exit_overlay_menu() -- then leave the alert
    end
    BluePercent:overlay_message(
        { "This card is not whitelisted!" },
        {
            {
                name = "Just Do It",
                func = "BP_temp_buy"
            }
        }
    )
end

function G.FUNCS.BP_whitelist(e)
    BluePercent.is_allowed = function(self) return true end
end

function G.FUNCS.BP_temp_buy(e)
    -- this function is automatically overwritten
    -- as needed, so that the "Buy Anyway" button
    -- works properly
end

function G.FUNCS.BP_lose(e)
    lose_game()
    G.FUNCS.exit_overlay_menu()
end

function G.FUNCS.BP_fuck_you(e)
    BluePercent:overlay_message(
        { "Lmao nice try" },
        {
            {
                name = "Perish",
                func = "BP_lose"
            }
        }
    )
end

function BluePercent:overlay_message(message, buttons)
	G.SETTINGS.paused = true
	local message_table = message
	local message_ui = {
		{
			n = G.UIT.R,
			config = {
				padding = 0.2,
				align = "cm",
			},
			nodes = {
				{
					n = G.UIT.T,
					config = {
						scale = 0.8,
						shadow = true,
						text = "Blue%",
						colour = G.C.BLUE,
					},
				},
			},
		},
	}

	for _, v in ipairs(message_table) do
		table.insert(message_ui, {
			n = G.UIT.R,
			config = {
				padding = 0.1,
				align = "cm",
			},
			nodes = {
				{
					n = G.UIT.T,
					config = {
						scale = 0.6,
						shadow = true,
						text = v,
						colour = G.C.UI.TEXT_LIGHT,
					},
				},
			},
		})
	end

	for key, value in pairs(buttons) do
    	table.insert(message_ui, {
    	    n = G.UIT.R,
    		config = {
    		    r = 0.1,
    			minw = 2.5,
    			colour = G.C.BLUE,
    			align = "cm",
    			padding = 0.1,
    			hover = true,
    			shadow = true,
                button = value.func
    		},
    		nodes = {
    		    {
          		    n = G.UIT.T,
         			config = {
         			    text = value.name,
            				colour = G.C.TEXT_LIGHT,
                            scale = 0.5,
         			}
    			}
    		}
    	})
	end

	G.FUNCS.overlay_menu({
		definition = create_UIBox_generic_options({
			contents = {
				{
					n = G.UIT.C,
					config = {
						padding = 0,
						align = "cm",
					},
					nodes = message_ui,
				},
			},
			padding = 0,
		}),
	})
end

SMODS.current_mod.config_tab = function()
    return {
        n = G.UIT.ROOT,
        config = {
            r = 0.1,
            minw = 5,
            align = "cm",
            padding = 0.2,
            colour = G.C.BLACK,
        },
        nodes = {
            {
                n = G.UIT.C,
                config = {
                    padding = 0.2,
                    align = "cm",
                },
                nodes = {
                    create_toggle({
                        id = "enable_club_kills",
                        label = "Non-clubs instantly gameover",
                        ref_table = SMODS.Mods["bluepercent"].config,
                        ref_value = "enable_club_kills"
                    }),
                    create_toggle({
                        id = "skip_penalty",
                        label = "Penalize selecting big blind and skipping small blind",
                        ref_table = SMODS.Mods["bluepercent"].config,
                        ref_value = "skip_penalty"
                    }),
                }
            },
        }
    }
end

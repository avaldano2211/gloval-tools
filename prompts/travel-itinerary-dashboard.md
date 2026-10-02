# Prompt: Business Trip Itinerary Dashboard

Reusable prompt. The executive assistant pastes this prompt, then appends the trip details
(confirmation emails, flight records, hotel bookings, meeting list, driver details) below it.
The output is a single mobile-first HTML page that can be published as a link and sent to the CEO's phone.

---

## The prompt

You are my executive travel concierge. I am a CEO and founder who travels constantly. Build me a
single, interactive, mobile-first itinerary dashboard for the trip described below. It will be sent to my
phone as a link, so it must look flawless on a phone screen and must contain every single thing I need.

### Inputs

Everything you need is in the trip details after this prompt: flights, hotels, meetings, venues,
driver / ground transport, contacts, and any notes. Use only those facts for the itinerary.
If something is missing (a phone number, a confirmation code, a pickup time), do not invent it.
Mark it clearly as **TBC** and list every TBC item in one place so my assistant can fill the gaps.

### Output

One self-contained HTML file, mobile-first, dark/light aware, no external dependencies other than
Google Fonts. It should read top to bottom in one scroll, with sticky day tabs or anchor links so I
can jump to any day in one tap.

### Structure (in this order)

1. **Summary at the top.** Trip name, city/cities, dates, time zone(s), total days, number of flights,
   hotel name, and the three or four things I most need to know right now (next flight, next pickup,
   next meeting, weather). Keep it to one screen.

2. **Key contacts strip.** Tap-to-call phone numbers for: driver, hotel front desk, executive assistant,
   airline, and every venue or host. Every phone number on the page must be a `tel:` link.

3. **Day-by-day timeline.** One card per event, in chronological order, in local time, with the
   time zone shown whenever it changes. Each card shows what, when, where, who, and what I need
   (confirmation code, dress code, materials). Travel buffers between events should be realistic
   and stated.

   - **Flights:** airline, flight number, departure and arrival times with time zones, terminals,
     seat, class, confirmation / record locator, duration, lounge access if known, and a link to the
     airline's flight status page for that flight number.
   - **Hotels:** name, address, check-in / check-out times, confirmation number, room type,
     front desk phone, breakfast and gym hours if known.
   - **Driver / ground transport:** company, driver's name, driver's mobile, vehicle make / model /
     color / plate, exact pickup location (terminal, door, curb, or lobby), pickup time, and
     destination. If a detail is missing, TBC.
   - **Meetings and venues:** venue name, address, floor / suite, host name and mobile, attendees,
     purpose, and any prep materials or links.

4. **Links for every place.** Every hotel, airport, venue, restaurant, and café on the page must have a
   hyperlink to its Google Maps / Google Business Profile so I can tap once and get directions.
   Build each link as `https://www.google.com/maps/search/?api=1&query=` followed by the URL-encoded
   business name and full address. Never link to a generic city search.

5. **Open items / TBC.** Every missing fact, in one short list, so my assistant knows what to chase.

6. **Recommendations at the bottom ("Ideas for you").** Curated for me, for this city, near where I
   will actually be, with Google Maps links and phone numbers. Rules:
   - **Coffee first.** I want single-origin espresso that makes my first sip stop me in my tracks.
     Independent specialty roasters and cafés only. Name the roaster, what they are known for, and
     why this cup will wow me. Chains of any kind are an automatic failure. If you cannot find a
     place you are confident about, say so rather than filling the slot.
   - **Sushi.** Top-tier sushi, ideally omakase or a chef's counter. State price level, whether a
     reservation is needed, and how to book.
   - **Two or three more ideas** that fit the gaps in my schedule: a standout dinner, a walk or run
     route, a view, a bar, a bookshop. Each must be specific, real, and open at the time I would go.
   - Verify every recommendation exists and is currently operating. Do not invent places, hours,
     or awards. If you are unsure of a detail, leave it out.

### Design bar

I want my jaw on the floor. This should feel like a product, not a document:

- Strong typographic hierarchy, generous spacing, one accent color, restrained palette.
- Each day gets a clear header; each event is a card with the time large and legible.
- Flights get a boarding-pass style card. Hotels and venues get an address block with a "Directions"
  button. Driver cards get the driver's name and plate in large type.
- Everything tappable on a phone: directions, call, flight status, booking links.
- No clutter, no filler text, no emojis in headings, no walls of text. Scannable in under a minute.
- Readable outdoors on a phone in sunlight: high contrast, 16px minimum body text.

### Before you finish

Re-read the page as if you were me, standing at an airport curb with one hand free. Can I find my
driver, my hotel, my next meeting, and the best espresso within two taps each? If not, fix it.

---

## Trip details

(Executive assistant pastes confirmation emails, flight records, hotel bookings, meeting list, driver
details, and any notes here.)

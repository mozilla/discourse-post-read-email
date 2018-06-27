import { acceptance } from "helpers/qunit-helpers"
import { parsePostData } from "helpers/create-pretender"
import user_fixtures from "fixtures/user_fixtures"

const response = (object, user_fields) => {
  const json = user_fixtures["/u/eviltrout.json"]
  json.user.can_edit = true
  json.user = Object.assign(json.user, user_fields)
  return [
    200,
    { "Content-Type": "application/json" },
    Object.assign(json, object)
  ]
}

const savePreferences = assert => {
  click(".save-user")
  assert.ok(!exists(".saved-user"), "it hasn't been saved yet")
  andThen(() => {
    assert.ok(exists(".saved-user"), "it displays the saved message")
  })
}

acceptance("Post Read Email", { loggedIn: true })

test("preference appears", assert => {
  visit("/u/eviltrout/preferences/emails")

  andThen(() => {
    assert.ok(exists("#post-read-email-preference"), "preference visible")
    assert.ok(exists("#post-read-email-preference input[type=checkbox]"), "checkbox visible")
  })
})

const checkbox_test_common = (assert, expected) => {
  server.put("/u/eviltrout.json", request => {
    const body = parsePostData(request.requestBody)
    assert.equal(body.custom_fields.mark_post_as_read_on_email, `${!expected}`, `mark_post_as_read_on_email is ${!expected}`)
    return response({ success: "OK" })
  })

  visit("/u/eviltrout/preferences/emails")

  andThen(() => {
    assert.equal(find("#post-read-email-preference input[type=checkbox]").prop("checked"), expected, `checkbox is ${expected ? "checked" : "unchecked"}`)
  })

  click("#post-read-email-preference input")

  andThen(() => {
    assert.equal(find("#post-read-email-preference input[type=checkbox]").prop("checked"), !expected, `checkbox is ${!expected ? "checked" : "unchecked"}`)
  })

  savePreferences(assert)
}

test("mark_post_as_read_on_email = true", assert => {
  server.get("/u/eviltrout.json", () => {
    return response(null, { custom_fields: { mark_post_as_read_on_email: true } })
  })

  checkbox_test_common(assert, true)
})

test("mark_post_as_read_on_email = 'true'", assert => {
  server.get("/u/eviltrout.json", () => {
    return response(null, { custom_fields: { mark_post_as_read_on_email: "true" } })
  })

  checkbox_test_common(assert, true)
})

test("mark_post_as_read_on_email = false", assert => {
  server.get("/u/eviltrout.json", () => {
    return response(null, { custom_fields: { mark_post_as_read_on_email: false } })
  })

  checkbox_test_common(assert, false)
})

test("mark_post_as_read_on_email = 'false'", assert => {
  server.get("/u/eviltrout.json", () => {
    return response(null, { custom_fields: { mark_post_as_read_on_email: "false" } })
  })

  checkbox_test_common(assert, false)
})

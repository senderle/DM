package edu.drew.dm;

import javax.ws.rs.DefaultValue;
import javax.ws.rs.GET;
import javax.ws.rs.HeaderParam;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.QueryParam;
import javax.ws.rs.RedirectionException;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.HttpHeaders;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.UriInfo;

/**
 * Logout routine for HTTP-based authentication.
 *
 * @author <a href="http://gregor.middell.net/">Gregor Middell</a>
 *
 * @see <a href="http://www.berenddeboer.net/rest/authentication.html#permanent-logout">berenddeboer.net</a>
 * @see <a href="http://trac-hacks.org/wiki/TrueHttpLogoutPatch">trac-hacks.org</a>
 */
@Path("/accounts/logout")
public class Logout {

    @GET
    public Response logout(@Context UriInfo ui,
                       @QueryParam("ts") @DefaultValue("0") long timestamp,
                       @HeaderParam(HttpHeaders.USER_AGENT) String userAgent) {
        if (timestamp == 0) {
            // we hit the logout resource for the first time: hand back a timestamp to the client
            timestamp = System.currentTimeMillis();
            throw new RedirectionException(
                    Response.Status.TEMPORARY_REDIRECT,
                    ui.getRequestUriBuilder().queryParam("ts", Long.toString(timestamp)).build()
            );
        }

        if ((System.currentTimeMillis() - timestamp) < 3000) {
            // Opera will not invalidate saved credentials unless we also ask for a different realm.
            final String realm = userAgent.contains("Opera")
                    ? "Please enter login data twice"
                    : Authentication.REALM;

            /*
             * it took the user less than 3 seconds to get back to us: unless she types really fast,
             * this comes from the redirect. Ask for re-authentication, thereby invalidating saved credentials.
             */
           throw Authentication.unauthorized(Authentication.REALM);
        }

        return Response.temporaryRedirect(ui.getBaseUriBuilder().path(Workspace.class).build()).build();

    }
}